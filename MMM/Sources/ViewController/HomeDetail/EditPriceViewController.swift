//
//  EditPriceViewController.swift
//  MMM
//
//  Created by geonhyeong on 2023/05/28.
//

import UIKit
import Combine
import Then
import SnapKit

final class EditPriceViewController: UIViewController {
	// MARK: - Properties
	private lazy var cancellable: Set<AnyCancellable> = .init()
	private let viewModel = PriceViewModel()
	private let editViewModel: EditActivityViewModel
	private lazy var isEarn: Bool = true
	weak var delegate: BottomSheetChild?
	
	// MARK: - UI Components
	private lazy var stackView = UIStackView() // title Label, 확인 Button
	private lazy var titleLabel = UILabel()
	private lazy var warningLabel = UILabel()
	private lazy var checkButton = UIButton()
	private lazy var priceTextField = UITextField()
	private lazy var buttonStackView = UIStackView()
	private lazy var earnButton = UIButton()
	private lazy var payButton = UIButton()

	init(editViewModel: EditActivityViewModel) {
		self.editViewModel = editViewModel
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
		if let newPosition = priceTextField.position(from: priceTextField.endOfDocument, offset: -2) {
			let newSelectedRange = priceTextField.textRange(from: newPosition, to: newPosition)
			priceTextField.selectedTextRange = newSelectedRange
		}
	}
}
//MARK: - Action
extension EditPriceViewController {
	// 외부에서 설정
	func setData(isEarn: Bool) {
		self.isEarn = isEarn
	}
	
	// MARK: - Private
	// 확인 후 닫힐때
	private func willDismiss() {
		guard let value = Int(viewModel.priceInput) else { return }
		
		editViewModel.type = isEarn ? "01" : "02" // 수입/지출
		editViewModel.amount = value
		delegate?.willDismiss()
	}
	
	// 유무에 따른 attribute 변경
	private func setValid(_ isVaild: Bool) {
		checkButton.setTitleColor(!viewModel.priceInput.isEmpty && isVaild ? R.Color.black : R.Color.gray500, for: .normal)
		checkButton.isEnabled = !viewModel.priceInput.isEmpty && isVaild
		
		// shake 에니메이션
		if !viewModel.priceInput.isEmpty && !isVaild {
			priceTextField.shake()
			warningLabel.isHidden = false
		} else {
			warningLabel.isHidden = true
		}
	}
	
	// 수입/지출 button
	private func didTogglePriceTypeButton(_ tag: Int) {
		earnButton = earnButton.then {
			$0.setTitleColor(tag == 0 ? R.Color.white : R.Color.gray400, for: .normal)
			$0.titleLabel?.font = tag == 0 ? R.Font.body2 : R.Font.prtendard(family: .medium, size: 14)
			$0.backgroundColor = tag == 0 ? R.Color.orange500 : R.Color.white
			$0.layer.borderWidth = tag == 0 ? 0 : 1
			$0.layer.borderColor = tag == 0 ? .none : R.Color.gray500.cgColor
		}
		
		payButton = payButton.then {
			$0.setTitleColor(tag == 1 ? R.Color.white : R.Color.gray400, for: .normal)
			$0.titleLabel?.font = tag == 1 ? R.Font.body2 : R.Font.prtendard(family: .medium, size: 14)
			$0.backgroundColor = tag == 1 ? R.Color.blue500 : R.Color.white
			$0.layer.borderWidth = tag == 1 ? 0 : 1
			$0.layer.borderColor = tag == 1 ? .none : R.Color.gray500.cgColor
		}
		
		isEarn = tag == 0 ? true : false
	}
}
//MARK: - Style & Layouts
private extension EditPriceViewController {
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
		
		earnButton.tapPublisherByTag
			.sinkOnMainThread(receiveValue: didTogglePriceTypeButton)
			.store(in: &cancellable)

		payButton.tapPublisherByTag
			.sinkOnMainThread(receiveValue: didTogglePriceTypeButton)
			.store(in: &cancellable)
		
		//MARK: output
		viewModel.isVaildByWon
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
			$0.text = "금액 수정"
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
			let price = editViewModel.amount
			$0.text = price.withCommas() + " 원"
			viewModel.priceInput = String(price)
			$0.placeholder = "원 단위로 입력"
			$0.font = R.Font.h2
			$0.textColor = R.Color.gray900
			$0.keyboardType = .numberPad 	// 숫자 키보드
			$0.tintColor = R.Color.gray400 	// cursor color
			$0.setNumberMode(unit: " 원") 	// 단위 설정
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
		
		buttonStackView = buttonStackView.then {
			$0.spacing = 24
			$0.distribution = .fillEqually
		}
		
		earnButton = earnButton.then {
			$0.setTitle("지출", for: .normal)
			$0.setTitleColor(R.Color.white, for: .normal)
			$0.titleLabel?.font = R.Font.body2
			$0.backgroundColor = R.Color.orange500
			$0.layer.cornerRadius = 4
			$0.tag = 0
		}
		
		payButton = payButton.then {
			$0.setTitle("수입", for: .normal)
			$0.setTitleColor(R.Color.gray400, for: .normal)
			$0.titleLabel?.font = R.Font.prtendard(family: .medium, size: 14)
			$0.backgroundColor = R.Color.white
			$0.layer.borderWidth = 1
			$0.layer.borderColor = R.Color.gray500.cgColor
			$0.layer.cornerRadius = 4
			$0.tag = 1
		}
		
		didTogglePriceTypeButton(editViewModel.type == "01" ? 0 : 1)
	}
	
	private func setLayout() {
		view.addSubviews(stackView, priceTextField, warningLabel, buttonStackView)
		stackView.addArrangedSubviews(titleLabel, checkButton)
		buttonStackView.addArrangedSubviews(earnButton, payButton)
		
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
		
		buttonStackView.snp.makeConstraints {
			$0.top.equalTo(priceTextField.snp.bottom).offset(46)
			$0.leading.trailing.equalToSuperview().inset(24)
			$0.height.equalTo(36)
		}
	}
}
