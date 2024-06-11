//
//  StatisticsBudgetBottomSheetViewController.swift
//  MMM
//
//  Created by geonhyeong on 5/13/24.
//

import UIKit
import SnapKit
import Then
import ReactorKit

// 상속하지 않으려면 final 꼭 붙이기
final class StatisticsBudgetBottomSheetViewController: BottomSheetViewController2, View {
	typealias Reactor = StatisticsBudgetBottomSheetReactor

	// MARK: - Properties
	private var curBudget: Int = 0
	private var totalSaving: Int = 0
	private var type: UIDatePicker.Mode = .date
	private var isDark: Bool = false // 다크 모드 지정
	private var height: CGFloat

	// MARK: - UI Components
	private lazy var containerView = UIView()
	private lazy var titleLabel = UILabel()
	private lazy var contentLabel = UILabel()
	private lazy var buttonStackView = UIStackView()
	private lazy var chageButton = UIButton()
	private lazy var sameButton = UIButton()

	init(curBudget: Int, totalSaving: Int, type: UIDatePicker.Mode = .date, date: Date = Date(), height: CGFloat, isDark: Bool = false) {
		self.curBudget = curBudget
		self.totalSaving = totalSaving
		self.height = height
		self.type = type
		self.isDark = isDark
		super.init(mode: .fixed, isDark: isDark)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func touchesBegan(_: Set<UITouch>, with _: UIEvent?) {
		view.endEditing(true)
	}
	
	func bind(reactor: StatisticsBudgetBottomSheetReactor) {
		bindState(reactor)
		bindAction(reactor)
	}
}
//MARK: - Bind
extension StatisticsBudgetBottomSheetViewController {
	// MARK: 데이터 변경 요청 및 버튼 클릭시 요청 로직(View -> Reactor)
	private func bindAction(_ reactor: StatisticsBudgetBottomSheetReactor) {
		// 예산 변경하기
		chageButton.rx.tap
			.withUnretained(self)
			.map { .change }
			.bind(to: reactor.action)
			.disposed(by: disposeBag)

		// 똑같이 적용하기
		sameButton.rx.tap
			.withUnretained(self)
			.map { .setApply }
			.bind(to: reactor.action)
			.disposed(by: disposeBag)
	}
	
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: StatisticsBudgetBottomSheetReactor) {
		reactor.state
			.map { $0.dismiss }
			.distinctUntilChanged()
			.filter { $0 == true }
			.subscribe(onNext: { [weak self] _ in
				self?.dismiss(animated: true)
			})
			.disposed(by: disposeBag)
	}
}
//MARK: - Action
extension StatisticsBudgetBottomSheetViewController {
	private func setMutiText() -> NSMutableAttributedString {
		let attributedText1 = NSMutableAttributedString(string: "가장 최근에 설정한 지출 예산인\n")
		let attributedText2 = NSMutableAttributedString(string: "{\(curBudget.withCommas())}원")
		let attributedText3 = NSMutableAttributedString(string: "을 적용할까요?")
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineSpacing = 5

		let textAttributes: [NSAttributedString.Key : Any] = [
			NSAttributedString.Key.font: R.Font.h5,
			NSAttributedString.Key.foregroundColor: R.Color.black,
			NSAttributedString.Key.paragraphStyle: paragraphStyle
		]
		
		attributedText1.addAttributes(textAttributes, range: NSMakeRange(0, attributedText1.length))
				
		let textAttributes2: [NSAttributedString.Key : Any] = [
			NSAttributedString.Key.font: R.Font.h5,
			NSAttributedString.Key.foregroundColor: R.Color.orange500
		]
		attributedText2.addAttributes(textAttributes2, range: NSMakeRange(0, attributedText2.length))
		attributedText3.addAttributes(textAttributes, range: NSMakeRange(0, attributedText3.length))
		attributedText1.append(attributedText2)
		attributedText1.append(attributedText3)

		return attributedText1
	}
}
//MARK: - Attribute & Hierarchy & Layouts
extension StatisticsBudgetBottomSheetViewController {
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()
				
		containerView = containerView.then {
			$0.backgroundColor = isDark ? R.Color.gray900 : .white
		}
		
		titleLabel = titleLabel.then {
			$0.attributedText = setMutiText()
			$0.font = R.Font.h5
			$0.textAlignment = .center
			$0.numberOfLines = 2
		}
		
		contentLabel = contentLabel.then {
			let attrString = NSMutableAttributedString(string: "한 달에 이만큼 지출하면\n총 {\(totalSaving.withCommas())}원을 저축할 수 있어요")
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.lineSpacing = 5
			attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
			$0.attributedText = attrString
			$0.textColor = R.Color.gray800
			$0.font = R.Font.body1
			$0.textAlignment = .center
			$0.numberOfLines = 2
		}
		
		buttonStackView = buttonStackView.then {
			$0.spacing = 8
			$0.distribution = .fillEqually
		}
		
		chageButton = chageButton.then {
			$0.setTitle("예산 변경하기", for: .normal)
			$0.backgroundColor = R.Color.white
			$0.setTitleColor(R.Color.orange700, for: .normal)
			$0.setTitleColor(R.Color.orange700.withAlphaComponent(0.7), for: .highlighted)
			$0.contentHorizontalAlignment = .center
			$0.titleLabel?.font = R.Font.title1
			$0.layer.borderWidth = 1
			$0.layer.borderColor = R.Color.gray200.cgColor
			$0.layer.cornerRadius = 4
			$0.contentEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10) // touch 영역 늘리기
		}
		
		sameButton = sameButton.then {
			$0.setTitle("똑같이 적용하기", for: .normal)
			$0.setTitleColor(R.Color.gray100, for: .normal)
			$0.setTitleColor(R.Color.gray100.withAlphaComponent(0.7), for: .highlighted)
			$0.backgroundColor = R.Color.orange500
			$0.contentHorizontalAlignment = .center
			$0.titleLabel?.font = R.Font.title1
			$0.layer.cornerRadius = 4
			$0.contentEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10) // touch 영역 늘리기
		}
	}
	
	override func setHierarchy() {
		super.setHierarchy()
		
		buttonStackView.addArrangedSubviews(chageButton, sameButton)
		containerView.addSubviews(titleLabel, contentLabel, buttonStackView)
		addContentView(view: containerView)
	}
	
	override func setLayout() {
		super.setLayout()
		
		containerView.snp.makeConstraints {
			$0.height.equalTo(height - 32.0) // 32(Super Class의 Drag 영역)를 반드시 뺴줘야한다.
		}
		
		titleLabel.snp.makeConstraints {
			$0.top.equalToSuperview().inset(5)
			$0.centerX.equalToSuperview()
		}
		
		contentLabel.snp.makeConstraints {
			$0.top.equalTo(titleLabel.snp.bottom).offset(18)
			$0.centerX.equalToSuperview()
		}
		
		buttonStackView.snp.makeConstraints {
			$0.top.equalTo(contentLabel.snp.bottom).offset(25)
			$0.horizontalEdges.equalToSuperview().inset(23)
			$0.centerX.equalToSuperview()
		}
		
		chageButton.snp.makeConstraints {
			$0.height.equalTo(56)
		}
		
		sameButton.snp.makeConstraints {
			$0.height.equalTo(56)
		}
	}
}
