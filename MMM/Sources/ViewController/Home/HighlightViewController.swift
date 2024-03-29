//
//  HighlightViewController.swift
//  MMM
//
//  Created by geonhyeong on 2023/05/19.
//

import UIKit
import Combine
import Then
import SnapKit

final class HighlightViewController: UIViewController {
	// MARK: - Properties
	private lazy var cancellable: Set<AnyCancellable> = .init()
	private let viewModel = PriceViewModel()
	private let homeViewModel: HomeViewModel
	private var isEarn: Bool = true
	weak var delegate: BottomSheetChild?
	
	// MARK: - UI Components
	private lazy var stackView = UIStackView() // title Label, 확인 Button
	private lazy var titleLabel = UILabel()
	private lazy var warningLabel = UILabel()
	private lazy var checkButton = UIButton()
	private lazy var priceTextField = UITextField()
	
	init(homeViewModel: HomeViewModel) {
		self.homeViewModel = homeViewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	// Compile time에 error를 발생시키는 코드
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setup()		// 초기 셋업할 코드들
    }
	
	override func viewDidLayoutSubviews() {
		// Underline 호출
		priceTextField.setUnderLine(color: R.Color.orange500)
		
		// cursor 위치 변경
		if let newPosition = priceTextField.position(from: priceTextField.endOfDocument, offset: -3) {
			let newSelectedRange = priceTextField.textRange(from: newPosition, to: newPosition)
			priceTextField.selectedTextRange = newSelectedRange
		}
	}
}
//MARK: - Action
extension HighlightViewController {
	// 외부에서 설정
	func setData(isEarn: Bool) {
		self.isEarn = isEarn
		DispatchQueue.main.async {
			self.titleLabel.text = isEarn ? "수입 하이라이트 금액" : "지출 하이라이트 금액"
		}
	}
	
	// MARK: - Private
	// 확인 후 닫힐때
	private func willDismiss() {
		guard let value = Int(viewModel.priceInput) else { return }
		if isEarn { // 수입
            Tracking.CalSetting.incomeLogEvent(value * 10_000)
			homeViewModel.earnStandard = value * 10_000 // 만 단위
		} else { // 지출
            Tracking.CalSetting.expenseLogEvent(value * 10_000)
			homeViewModel.payStandard = value * 10_000
		}
		delegate?.willDismiss()
	}
	
	// 유무에 따른 attribute 변경
	private func setValid(_ isValid: Bool) {
		checkButton.setTitleColor(!viewModel.priceInput.isEmpty && isValid ? R.Color.black : R.Color.gray500, for: .normal)
		checkButton.isEnabled = !viewModel.priceInput.isEmpty && isValid
		
		// shake 에니메이션
		if !viewModel.priceInput.isEmpty && !isValid {
			priceTextField.shake()
			warningLabel.isHidden = false
		} else {
			warningLabel.isHidden = true
		}
	}
}
//MARK: - Attribute & Hierarchy & Layouts
private extension HighlightViewController {
	// 초기 셋업할 코드들
	func setup() {
		bind()
		setAttribute()
		setLayout()
	}
	
	private func bind() {
		//MARK: input
		checkButton.tapPublisher
			.sinkOnMainThread(receiveValue: willDismiss)
			.store(in: &cancellable)
		
		priceTextField.textPublisher
			.map{String(Array($0).filter{$0.isNumber})} // 숫자만 추출
			.assignOnMainThread(to: \.priceInput, on: viewModel)
			.store(in: &cancellable)
		
		//MARK: output
		viewModel.isValid
			.sinkOnMainThread(receiveValue: setValid)
			.store(in: &cancellable)
	}
	
	private func setAttribute() {
		// [view]
		view.backgroundColor = R.Color.white
		
		stackView = stackView.then {
			$0.axis = .horizontal
			$0.alignment = .center
			$0.distribution = .equalCentering
		}
		
		titleLabel = titleLabel.then {
			$0.text = "수입 하이라이트 금액"
			$0.font = R.Font.h5
			$0.textColor = R.Color.black
			$0.textAlignment = .left
		}
		
		checkButton = checkButton.then {
			$0.setTitle("확인", for: .normal)
			$0.setTitleColor(R.Color.gray500, for: .normal)
			$0.setTitleColor(R.Color.black.withAlphaComponent(0.7), for: .highlighted)
			$0.contentHorizontalAlignment = .right
			$0.titleLabel?.font = R.Font.title3
			$0.contentEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10) // touch 영역 늘리기
			$0.isEnabled = false // 초기 비활성화
		}
		
		priceTextField = priceTextField.then {
			let price = isEarn ? homeViewModel.earnStandard / 10_000 : homeViewModel.payStandard / 10_000
			$0.text = price.withCommas() + " 만원"
			viewModel.priceInput = String(price)
			$0.placeholder = "만원 단위로 입력"
			$0.font = R.Font.h2
			$0.textColor = R.Color.gray900
			$0.keyboardType = .numberPad 	// 숫자 키보드
			$0.tintColor = R.Color.gray400 	// cursor color
			$0.setNumberMode(unit: "만원") 	// 단위 설정
			$0.setClearButton(with: R.Icon.cancel, mode: .whileEditing) // clear 버튼
			$0.becomeFirstResponder()
		}
		
		warningLabel = warningLabel.then {
			$0.text = "최대 작성 단위을 넘어선 금액이에요. (최대 1억)"
			$0.font = R.Font.body3
			$0.textColor = R.Color.red500
			$0.textAlignment = .left
			$0.isHidden = true
		}
	}
	
	private func setLayout() {
		view.addSubviews(stackView, priceTextField, warningLabel)
		stackView.addArrangedSubviews(titleLabel, checkButton)

		stackView.snp.makeConstraints {
			$0.top.equalToSuperview()
			$0.leading.equalToSuperview().inset(24)
			$0.trailing.equalToSuperview().inset(28)
		}
		
		priceTextField.snp.makeConstraints {
			$0.top.equalTo(stackView.snp.bottom).offset(24)
			$0.leading.trailing.equalToSuperview().inset(24)
		}
		
		warningLabel.snp.makeConstraints {
			$0.top.equalTo(priceTextField.snp.bottom).offset(12)
			$0.leading.trailing.equalToSuperview().inset(24)
		}
	}
}
