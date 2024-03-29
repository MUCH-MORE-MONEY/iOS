//
//  AddViewController.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/04/14.
//

import UIKit
import Combine
import Then
import SnapKit
import FirebaseAnalytics

final class AddViewController: BaseViewControllerWithNav {
	// MARK: - Properties
	private lazy var cancellable: Set<AnyCancellable> = .init()
	private var viewModel = EditActivityViewModel(isAddModel: true)
	private var bottomConstraint: Constraint!
	private var isFirst: Bool = true
	private var bottomPadding: CGFloat {
		return UIApplication.shared.windows.first{$0.isKeyWindow}?.safeAreaInsets.bottom ?? 0
	}
	
	// MARK: - UI Components
	private lazy var scrollView = UIScrollView()
	private lazy var contentView = UIView()
	
	private lazy var priceView = UIView()
	private lazy var priceLabel = UILabel()
	private lazy var priceTextField = UITextField()
	private lazy var warningLabel = UILabel()
	
	private lazy var dateView = UIView()
	private lazy var dateLabel = UILabel()
	private lazy var dateButton = UIButton()
	
	private lazy var typeView = UIView()
	private lazy var isEarn: Bool = true
	private lazy var typeLabel = UILabel()
	private lazy var buttonStackView = UIStackView()
	private lazy var payButton = UIButton()  // 지출
	private lazy var earnButton = UIButton() // 수입
	
	private lazy var nextFirstButton = UIButton()
	private lazy var nextSecondButton = UIButton()
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		// Underline 호출
		priceTextField.setUnderLine(color: R.Color.orange500)
		dateButton.setUnderLine(color: R.Color.orange500)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .dark
		
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
		
		// Home Loading을 보여줄지 판단
		Constants.setKeychain(false, forKey: Constants.KeychainKey.isHomeLoading)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		if isFirst { // 처음 들어올 경우만,
			self.priceTextField.becomeFirstResponder()
			isFirst = false
		}
		
		// cursor 위치 변경
		if let newPosition = priceTextField.position(from: priceTextField.endOfDocument, offset: -1) {
			let newSelectedRange = priceTextField.textRange(from: newPosition, to: newPosition)
			priceTextField.selectedTextRange = newSelectedRange
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .light
		
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
	}
    
}
//MARK: - Action
extension AddViewController {
	// MARK: - Private
	// 유무에 따른 attribute 변경
	private func setValid(_ isValid: Bool) {
		nextFirstButton.setTitleColor(!viewModel.priceInput.isEmpty && isValid ? R.Color.white : R.Color.gray400, for: .normal)
		nextFirstButton.isEnabled = !viewModel.priceInput.isEmpty && isValid
		nextSecondButton.isEnabled = !viewModel.priceInput.isEmpty && isValid
		warningLabel.isHidden = !viewModel.priceInput.isEmpty && isValid
		
		// shake 에니메이션
		if !viewModel.priceInput.isEmpty && !isValid {
			priceTextField.shake()
			warningLabel.isHidden = false
		} else {
			warningLabel.isHidden = true
		}
	}
	
	// Set Button Title
	private func setTitle(_ date: Date) {
		dateButton.setTitle(date.getFormattedDate(format: "yyyy년 MM월 dd일"), for: .normal)
	}
	
	// 첫번째 버튼에 대한 Animation
	private func setLayoutPriceView() {
		dateView.isHidden = false
		
		priceView.snp.remakeConstraints {
			$0.top.equalTo(dateButton.snp.bottom).offset(46)
			$0.leading.trailing.equalToSuperview().inset(24)
			$0.height.equalTo(70)
		}
		
		UIView.animate(withDuration: 0.05, animations: self.view.layoutIfNeeded)
	}
	
	// 두번째 버튼에 대한 Animation
	private func setLayoutDateView() {
        Tracking.FinActAddPage.inputTypeLogEvent("01")
        
		typeView.isHidden = false
		nextSecondButton.isHidden = false
		
		dateView.snp.remakeConstraints {
			$0.top.equalTo(typeView.snp.bottom).offset(40)
			$0.leading.trailing.equalToSuperview().inset(24)
			$0.height.equalTo(70)
		}
		
		UIView.animate(withDuration: 0.05, animations: self.view.layoutIfNeeded)
	}
	
	// Push Date BottomSheet
	private func didTapDateButton() {
		view.endEditing(true)
		
		setLayoutPriceView()
        
        // 캘린더에서 선택된 날짜를 경제활동 추가에서 디폴트로 설정하기 위해서 추가
        viewModel.date = Common.getCalendarSelectedDate()
        let picker = DatePickerViewController(viewModel: viewModel, date: viewModel.date ?? Common.getCalendarSelectedDate())
		
		let bottomSheetVC = BottomSheetViewController(contentViewController: picker)
		picker.delegate = bottomSheetVC
		picker.setData(title: "경제활동 날짜 선택", isDark: true)
		bottomSheetVC.modalPresentationStyle = .overFullScreen
		bottomSheetVC.setSetting(height: 375, isDark: true)
		
		viewModel.createAt = viewModel.date?.getFormattedDate(format: "yyyyMMdd") ?? ""
		
		self.present(bottomSheetVC, animated: false, completion: nil) // fasle(애니메이션 효과로 인해 부자연스럽움 제거)
	}
	
	// 수입/지출 button
	private func didTogglePriceTypeButton(_ tag: Int) {
		view.endEditing(true)
		
		payButton = payButton.then {
			$0.setTitleColor(tag == 0 ? R.Color.white : R.Color.gray400, for: .normal)
			$0.titleLabel?.font = tag == 0 ? R.Font.body2 : R.Font.prtendard(family: .medium, size: 14)
			$0.backgroundColor = tag == 0 ? R.Color.orange500 : R.Color.gray900
			$0.layer.borderWidth = tag == 0 ? 0 : 1
			$0.layer.borderColor = tag == 0 ? .none : R.Color.gray500.cgColor
		}
		
		earnButton = earnButton.then {
			$0.setTitleColor(tag == 1 ? R.Color.white : R.Color.gray400, for: .normal)
			$0.titleLabel?.font = tag == 1 ? R.Font.body2 : R.Font.prtendard(family: .medium, size: 14)
			$0.backgroundColor = tag == 1 ? R.Color.blue500 : R.Color.gray900
			$0.layer.borderWidth = tag == 1 ? 0 : 1
			$0.layer.borderColor = tag == 1 ? .none : R.Color.gray500.cgColor
		}
		
		isEarn = tag == 0 ? true : false
        
        Tracking.FinActAddPage.inputTypeLogEvent(tag == 0 ? "01" : "02")

	}
	
	@objc private func keyboardWillShow(_ notification: NSNotification) {
		moveViewWithKeyboard(notification: notification, keyboardWillShow: true)
	}
	
	@objc private func keyboardWillHide(_ notification: NSNotification) {
		moveViewWithKeyboard(notification: notification, keyboardWillShow: false)
	}
	
	private func moveViewWithKeyboard(notification: NSNotification, keyboardWillShow: Bool) {
		// Keyboard's size
		guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
		let keyboardHeight = keyboardSize.height
		
		// Keyboard's animation duration
		let keyboardDuration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
		
		// Keyboard's animation curve
		let keyboardCurve = UIView.AnimationCurve(rawValue: notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! Int)!
		
		let isSmall = UIScreen.main.bounds.size.height <= 667.0 // 4.7 inch

		if isSmall && !typeView.isHidden {
			contentView.snp.updateConstraints {
				$0.top.equalTo(scrollView.contentLayoutGuide).offset(keyboardWillShow ? -50 : 0)
			}
		}

		if keyboardWillShow {
			if let tabBarHeight = self.tabBarController?.tabBar.frame.height {
				bottomConstraint.update(inset: keyboardHeight - tabBarHeight)
			} else {
				bottomConstraint.update(inset: keyboardHeight)
			}
			nextFirstButton.isHidden = false
		} else {
			bottomConstraint.update(inset: 0)
			nextFirstButton.isHidden = true
		}
		
		// 키보드 애니메이션과 동일한 방식으로 보기 애니메이션 적용하기
		let animator = UIViewPropertyAnimator(duration: keyboardDuration, curve: keyboardCurve) { [weak self] in
			// Update Constraints
			self?.view.layoutIfNeeded()
		}
		
		animator.startAnimation()
	}
	
	private func didTapNextSecondButton() {
		viewModel.amount = Int(viewModel.priceInput)!
		viewModel.type = isEarn ? "01" : "02"
		let vc = AddDetailViewController(viewModel: viewModel)
		vc.hidesBottomBarWhenPushed = true
		navigationController?.pushViewController(vc, animated: true)
        Tracking.FinActAddPage.nextBtnDateLogEvent()
	}
}
//MARK: - Attribute & Hierarchy & Layouts
extension AddViewController {
	override func setBind() {
		//MARK: input
		view.gesturePublisher()
			.sinkOnMainThread(receiveValue: { _ in
				// Keyboard 내리기
				if !self.viewModel.priceInput.isEmpty {
					self.view.endEditing(true)
				}
			}).store(in: &cancellable)
		
		priceTextField.textPublisher
			.map{String(Array($0).filter{$0.isNumber})} // 숫자만 추출
			.assignOnMainThread(to: \.priceInput, on: viewModel)
			.store(in: &cancellable)
		
		nextFirstButton.tapPublisher
			.sinkOnMainThread(receiveValue: {
				guard self.dateView.isHidden else { // 애니메이션이 다 끝났을 경우
					self.view.endEditing(true) // 키보드 내리기
					return
				}
                Tracking.FinActAddPage.nextBtnAmountLogEvent()
                self.didTapDateButton()
			})
			.store(in: &cancellable)
		
		dateButton.tapPublisher
			.sinkOnMainThread(receiveValue: didTapDateButton)
			.store(in: &cancellable)
		
		payButton.tapPublisherByTag
			.sinkOnMainThread(receiveValue: didTogglePriceTypeButton)
			.store(in: &cancellable)
		
		earnButton.tapPublisherByTag
			.sinkOnMainThread(receiveValue: didTogglePriceTypeButton)
			.store(in: &cancellable)
		
		nextSecondButton.tapPublisher
			.sinkOnMainThread(receiveValue: didTapNextSecondButton)
			.store(in: &cancellable)
		
		//MARK: output
		viewModel.isValidByWon
			.sinkOnMainThread(receiveValue: setValid)
			.store(in: &cancellable)
		
		// Date Picker
		viewModel.$date
			.sinkOnMainThread(receiveValue: { [weak self] date in
				guard let date = date else { return }
				self?.setTitle(date)
				self?.setLayoutDateView()
				self?.viewModel.createAt = date.getFormattedDate(format: "yyyyMMdd")
			}).store(in: &cancellable)
	}
	
	override func setAttribute() {
		// [view]
		view.backgroundColor = R.Color.gray900
		navigationItem.title = "경제활동 추가"
		
		scrollView = scrollView.then {
			$0.showsVerticalScrollIndicator = false
			$0.isScrollEnabled = false
		}
		
		contentView = contentView.then {
			$0.backgroundColor = R.Color.gray900
		}
		
		priceLabel = priceLabel.then {
			$0.text = "이 경제활동에 사용된 금액은"
			$0.font = R.Font.title3
			$0.textColor = R.Color.gray200
			$0.textAlignment = .left
			$0.addImageViewOnRight(image: R.Icon.checkOrange24)
		}
		
		priceTextField = priceTextField.then {
			$0.text = "원"
			$0.placeholder = "원 단위로 입력"
			$0.font = R.Font.h2
			$0.textColor = R.Color.white
			$0.keyboardType = .numberPad 	// 숫자 키보드
			$0.tintColor = R.Color.gray400 	// cursor color
			$0.setNumberMode(unit: "원") 	// 단위 설정
			$0.setClearButton(with: R.Icon.cancel, mode: .always) // clear 버튼
		}
		
		warningLabel = warningLabel.then {
			$0.text = "최대 작성 단위을 넘어선 금액이에요. (최대 1억)"
			$0.font = R.Font.body3
			$0.textColor = R.Color.red500
			$0.textAlignment = .left
			$0.isHidden = true
		}
		
		dateView = dateView.then {
			$0.backgroundColor = R.Color.gray900
			$0.isHidden = true
		}
		
		dateLabel = dateLabel.then {
			$0.text = "이 경제활동을 한 날짜는"
			$0.font = R.Font.title3
			$0.textColor = R.Color.gray200
			$0.textAlignment = .left
			$0.addImageViewOnRight(image: R.Icon.checkOrange24)
		}
		
		dateButton = dateButton.then {
			setTitle(Common.getCalendarSelectedDate())
			$0.setTitleColor(R.Color.gray100, for: .normal)
			$0.setTitleColor(R.Color.gray100.withAlphaComponent(0.7), for: .highlighted)
			$0.backgroundColor = R.Color.gray900
			$0.titleLabel?.font = R.Font.h2
			$0.contentHorizontalAlignment = .left // 왼쪽 정렬
			$0.layer.cornerRadius = 4
		}
		
		typeView = typeView.then {
			$0.isHidden = true
		}
		
		typeLabel = typeLabel.then {
			$0.text = "이 경제활동의 성격은"
			$0.font = R.Font.title3
			$0.textColor = R.Color.gray200
			$0.textAlignment = .left
			$0.addImageViewOnRight(image: R.Icon.checkOrange24)
		}
		
		payButton = payButton.then {
			$0.setTitle("지출", for: .normal)
			$0.setTitleColor(R.Color.white, for: .normal)
			$0.titleLabel?.font = R.Font.body2
			$0.backgroundColor = R.Color.orange500
			$0.layer.cornerRadius = 4
			$0.tag = 0
		}
		
		earnButton = earnButton.then {
			$0.setTitle("수입", for: .normal)
			$0.setTitleColor(R.Color.gray400, for: .normal)
			$0.titleLabel?.font = R.Font.prtendard(family: .medium, size: 14)
			$0.backgroundColor = R.Color.gray900
			$0.layer.borderWidth = 1
			$0.layer.borderColor = R.Color.gray500.cgColor
			$0.layer.cornerRadius = 4
			$0.tag = 1
		}
		
		buttonStackView = buttonStackView.then {
			$0.spacing = 9
			$0.distribution = .fillEqually
		}
		
		nextFirstButton = nextFirstButton.then {
			$0.setTitle("다음", for: .normal)
			$0.setTitleColor(R.Color.gray100, for: .normal)
			$0.setTitleColor(R.Color.gray100.withAlphaComponent(0.7), for: .highlighted)
			$0.setBackgroundColor(R.Color.orange500, for: .normal)
			$0.titleLabel?.font = R.Font.title1
			$0.isEnabled = false
		}
		
		nextSecondButton = nextSecondButton.then {
			$0.setTitle("다음", for: .normal)
			$0.setTitleColor(R.Color.gray100, for: .normal)
			$0.setTitleColor(R.Color.gray100.withAlphaComponent(0.7), for: .highlighted)
			$0.setBackgroundColor(R.Color.orange500, for: .normal)
			$0.titleLabel?.font = R.Font.title1
			$0.setButtonLayer()
			$0.isEnabled = false
			$0.isHidden = true
		}
	}
	
	override func setLayout() {
		view.addSubviews(scrollView, nextFirstButton, nextSecondButton)
		scrollView.addSubview(contentView)
		contentView.addSubviews(priceView, dateView, typeView)
		buttonStackView.addArrangedSubviews(payButton, earnButton)
		priceView.addSubviews(priceLabel, priceTextField, warningLabel)
		dateView.addSubviews(dateLabel, dateButton)
		typeView.addSubviews(typeLabel, buttonStackView)
		
		scrollView.snp.makeConstraints {
			$0.top.equalTo(view.safeAreaLayoutGuide)
			$0.leading.trailing.equalToSuperview()
			$0.bottom.equalTo(view)
		}
		
		contentView.snp.makeConstraints {
			$0.edges.equalTo(scrollView.contentLayoutGuide)
			$0.width.equalTo(scrollView.frameLayoutGuide)
			$0.height.equalTo(scrollView)
		}
		
		priceView.snp.makeConstraints {
			$0.top.equalToSuperview().inset(40)
			$0.leading.trailing.equalToSuperview().inset(24)
			$0.bottom.lessThanOrEqualTo(nextFirstButton.snp.top).offset(16)
			$0.height.equalTo(70)
		}
		
		priceLabel.snp.makeConstraints {
			$0.top.equalToSuperview()
			$0.leading.trailing.lessThanOrEqualToSuperview()
		}
		
		priceTextField.snp.makeConstraints {
			$0.top.equalTo(priceLabel.snp.bottom).offset(20)
			$0.leading.trailing.equalToSuperview()
		}
		
		warningLabel.snp.makeConstraints {
			$0.top.equalTo(priceTextField.snp.bottom).offset(12)
			$0.leading.trailing.equalToSuperview()
		}
		
		dateView.snp.makeConstraints {
			$0.top.equalToSuperview().inset(40)
			$0.leading.trailing.equalToSuperview().inset(24)
			$0.height.equalTo(70)
		}
		
		dateLabel.snp.makeConstraints {
			$0.top.equalToSuperview()
			$0.leading.trailing.lessThanOrEqualToSuperview()
		}
		
		dateButton.snp.makeConstraints {
			$0.top.equalTo(dateLabel.snp.bottom).offset(20)
			$0.leading.trailing.equalToSuperview()
		}
		
		typeView.snp.makeConstraints {
			$0.top.equalToSuperview().inset(40)
			$0.leading.trailing.equalToSuperview().inset(24)
			$0.height.equalTo(70)
		}
		
		typeLabel.snp.makeConstraints {
			$0.top.equalToSuperview()
			$0.leading.trailing.lessThanOrEqualToSuperview()
		}
		
		buttonStackView.snp.makeConstraints {
			$0.top.equalTo(typeLabel.snp.bottom).offset(15)
			$0.leading.trailing.equalToSuperview()
			$0.height.equalTo(36)
		}
		
		nextFirstButton.snp.makeConstraints {
			$0.leading.trailing.equalToSuperview()
			bottomConstraint = $0.bottom.equalToSuperview().inset(6).constraint
			$0.height.equalTo(56)
		}
		
		nextSecondButton.snp.makeConstraints {
			$0.leading.trailing.equalToSuperview().inset(24)
			$0.bottom.equalToSuperview().inset(40)
			$0.height.equalTo(56)
		}
	}
}
