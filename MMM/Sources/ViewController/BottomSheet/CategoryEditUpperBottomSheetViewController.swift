//
//  CategoryEditUpperBottomSheetViewController.swift
//  MMM
//
//  Created by geonhyeong on 10/7/23.
//

import UIKit
import SnapKit
import Then
import ReactorKit

// 상속하지 않으려면 final 꼭 붙이기
final class CategoryEditUpperBottomSheetViewController: BottomSheetViewController2, View {
	typealias Reactor = CategoryEditUpperBottomSheetReactor
	// MARK: - Sub Type
	
	// MARK: - Properties
	private var titleStr: String = ""
	private var categoryHeader: CategoryHeader
	private var isDark: Bool = false // 다크 모드 지정
	private var height: CGFloat
	private var heightConstraint: Constraint!

	// MARK: - UI Components
	private lazy var containerView = UIView()
	private lazy var stackView = UIStackView() // Title Label, Button
	private lazy var buttonStackView = UIStackView() // 삭제, 확인 Button
	private lazy var titleLabel = UILabel()
	private lazy var warningLabel = UILabel()
	private lazy var deleteButton = UIButton()
	private lazy var checkButton = UIButton()
	private lazy var textField = UITextField()

	init(title: String, categoryHeader: CategoryHeader, height: CGFloat, sheetMode: BottomSheetViewController2.Mode = .drag, isDark: Bool = false) {
		self.titleStr = title
		self.categoryHeader = categoryHeader
		self.height = height
		self.isDark = isDark
		super.init(mode: sheetMode, isDark: isDark)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	
	override func touchesBegan(_: Set<UITouch>, with _: UIEvent?) {
		// 배경을 누르면 작동
		view.endEditing(true)
	}
	
	override func viewDidLayoutSubviews() {
		// TextField에 밑줄 추가
		textField.setUnderLine(color: R.Color.orange500)
	}
	
	func bind(reactor: CategoryEditUpperBottomSheetReactor) {
		bindState(reactor)
		bindAction(reactor)
	}
}
//MARK: - Bind
extension CategoryEditUpperBottomSheetViewController {
	// MARK: 데이터 변경 요청 및 버튼 클릭시 요청 로직(View -> Reactor)
	private func bindAction(_ reactor: CategoryEditUpperBottomSheetReactor) {
		// 확인 버튼
		checkButton.rx.tap
			.map { .didTapEdit(self.tranformCategoryEdit()) }
			.bind(to: reactor.action)
			.disposed(by: disposeBag)
		
		// 삭제 버튼
		deleteButton.rx.tap
			.bind(onNext: didTapDeleteButton)
			.disposed(by: disposeBag)
		
		textField.rx.text.orEmpty
			.map { .inputEditText($0) }
			.bind(to: reactor.action)
			.disposed(by: disposeBag)
	}
	
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: CategoryEditUpperBottomSheetReactor) {
		
		reactor.state
			.map { $0.isEditValid }
			.subscribe(onNext: { [weak self] isValid in
				guard let self = self, let text = self.textField.text else {
					return
				}
				
				// shake 에니메이션
				// 9글자까지 입력 가능
				if !text.isEmpty && text.count >= 9 {
					if text.count > 9 {
						self.textField.text?.removeLast()
					}
					self.textField.shake()
				}
				
				// 확인 버튼 비활성화
				self.checkButton.isEnabled = !text.isEmpty && isValid
				self.checkButton.setTitleColor(!text.isEmpty && isValid ? R.Color.gray900 : R.Color.gray500, for: .normal)

				self.textField.textColor = isValid ? R.Color.gray900 : R.Color.red500
				self.warningLabel.isHidden = isValid
			})
			.disposed(by: disposeBag)
		
		reactor.state
			.map { $0.dismiss }
			.distinctUntilChanged()
			.filter { $0 }
			.subscribe(onNext: { [weak self] _ in
				self?.dismiss(animated: true)
			})
			.disposed(by: disposeBag)
	}
}
//MARK: - Action
extension CategoryEditUpperBottomSheetViewController: CustomAlertDelegate {
	func tranformCategoryEdit() -> CategoryHeader {
		guard let text = textField.text else { return self.categoryHeader }
		
		var categoryHeader = self.categoryHeader
		categoryHeader.title = text
		return categoryHeader
	}
	
	func didTapDeleteButton() {
		showAlert(alertType: .canCancel, titleText: "카테고리 유형을 삭제하시겠습니까?", contentText: "해당 유형의 카테고리가 모두 삭제되며\n담겨있는 경제활동은 기타 카테고리로 이동됩니다.", confirmButtonText: "삭제하기")
	}
	
	func didAlertCofirmButton() {
		// 카테고리 삭제하기
		reactor?.action.onNext(.delete(categoryHeader))
	}
	
	func didAlertCacelButton() { }
	
	@objc func keyboardWillShow(_ notification: NSNotification) {
		moveViewWithKeyboard(notification: notification, keyboardWillShow: true)
	}
	
	@objc func keyboardWillHide(_ notification: NSNotification) {
		moveViewWithKeyboard(notification: notification, keyboardWillShow: false)
	}
	
	func moveViewWithKeyboard(notification: NSNotification, keyboardWillShow: Bool) {
		// Keyboard's size
		guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
		let keyboardHeight = keyboardSize.height
		
		// Keyboard's animation duration
		let keyboardDuration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
		
		// Keyboard's animation curve
		let keyboardCurve = UIView.AnimationCurve(rawValue: notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! Int)!

		if keyboardWillShow {
			heightConstraint.update(offset: height - 32.0 + keyboardHeight)
		} else {
			heightConstraint.update(offset: height - 32.0)
		}
		
		// 키보드 애니메이션과 동일한 방식으로 보기 애니메이션 적용하기
		let animator = UIViewPropertyAnimator(duration: keyboardDuration, curve: keyboardCurve) { [weak self] in
			// Update Constraints
			self?.view.layoutIfNeeded()
		}
		
		animator.startAnimation()
	}

}
//MARK: - Attribute & Hierarchy & Layouts
extension CategoryEditUpperBottomSheetViewController {
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()
		
		stackView = stackView.then {
			$0.axis = .horizontal
			$0.alignment = .center
			$0.distribution = .equalCentering
		}
		
		buttonStackView = buttonStackView.then {
			$0.axis = .horizontal
			$0.alignment = .center
			$0.spacing = 18
			$0.distribution = .equalSpacing
		}
		
		titleLabel = titleLabel.then {
			$0.text = titleStr
			$0.font = R.Font.h5
			$0.textColor = isDark ? R.Color.gray200 : R.Color.black
			$0.textAlignment = .left
		}
		
		deleteButton = deleteButton.then {
			$0.setTitle("삭제", for: .normal)
			$0.setTitleColor(R.Color.red500, for: .normal)
			$0.setTitleColor(R.Color.red500.withAlphaComponent(0.7), for: .highlighted)
			$0.contentHorizontalAlignment = .center
			$0.titleLabel?.font = R.Font.title3
			$0.contentEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10) // touch 영역 늘리기
		}
		
		checkButton = checkButton.then {
			$0.setTitle("확인", for: .normal)
			$0.setTitleColor(isDark ? R.Color.gray200 : R.Color.black, for: .normal)
			$0.setTitleColor(isDark ? R.Color.gray200.withAlphaComponent(0.7) : R.Color.black.withAlphaComponent(0.7), for: .highlighted)
			$0.contentHorizontalAlignment = .right
			$0.titleLabel?.font = R.Font.title3
			$0.contentEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10) // touch 영역 늘리기
		}
		
		textField = textField.then {
			$0.delegate = self
			$0.text = categoryHeader.title
			$0.placeholder = "카테고리 이름을 입력해주세요"
			$0.font = R.Font.h2
			$0.textColor = R.Color.gray900
			$0.tintColor = R.Color.gray400 	// cursor color
			$0.setClearButton(with: R.Icon.cancel, mode: .whileEditing) // clear 버튼
			$0.becomeFirstResponder()
		}
		
		warningLabel = warningLabel.then {
			$0.text = "최대 글자수를 넘어선 글자예요. (최대 8글자)"
			$0.font = R.Font.body3
			$0.textColor = R.Color.red500
			$0.textAlignment = .left
			$0.isHidden = true
		}
	}
	
	override func setHierarchy() {
		super.setHierarchy()
		
		containerView.addSubviews(stackView, textField, warningLabel)
		stackView.addArrangedSubviews(titleLabel, buttonStackView)
		buttonStackView.addArrangedSubviews(deleteButton, checkButton)
		addContentView(view: containerView)
	}
	
	override func setLayout() {
		super.setLayout()
		
		containerView.snp.makeConstraints {
			heightConstraint = $0.height.equalTo(height - 32.0).constraint // 32(Super Class의 Drag 영역)를 반드시 뺴줘야한다.
		}
		
		stackView.snp.makeConstraints {
			$0.top.equalToSuperview()
			$0.leading.equalToSuperview().inset(24)
			$0.trailing.equalToSuperview().inset(28)
		}
		
		textField.snp.makeConstraints {
			$0.top.equalTo(stackView.snp.bottom).offset(24)
			$0.leading.trailing.equalToSuperview().inset(24)
		}
		
		warningLabel.snp.makeConstraints {
			$0.top.equalTo(textField.snp.bottom).offset(12)
			$0.leading.trailing.equalToSuperview().inset(24)
		}
	}
}
// MARK: - UITextField Delegate
extension CategoryEditUpperBottomSheetViewController: UITextFieldDelegate {
	// text가 변경할지에 대한 delegate요청 메소드
	public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		// Back Space 감지
		if let char = string.cString(using: String.Encoding.utf8) {
			let isBackSpace = strcmp(char, "\\b")
			if isBackSpace == -92 {
				return true
			}
		}
		
		// oldString: 기존에 입력되었던 text
		guard let oldString = textField.text, oldString.count < 9 else { return false }
		return true
	}
}
