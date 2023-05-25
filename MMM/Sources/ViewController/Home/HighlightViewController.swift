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
	private let viewModel = HomeHighlightViewModel()
	private let homeViewModel: HomeViewModel
	weak var delegate: BottomSheetChild?

	// MARK: - UI Components
	private lazy var stackView = UIStackView() // title Label, 확인 Button
	private lazy var titleLabel = UILabel()
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
	
	// MARK: - UI Components
    override func viewDidLoad() {
        super.viewDidLoad()
		setup()		// 초기 셋업할 코드들
    }
	
	override func viewDidLayoutSubviews() {
		// Underline 호출
		priceTextFiled.setUnderLine(color: R.Color.orange500)
	}
}
//MARK: - Action
private extension HighlightViewController {
	// 닫힐때
	private func willDismiss() {
		delegate?.willDismiss()
	}
}
//MARK: - Style & Layouts
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
		
		priceTextFiled.textPublisher
			.assignOnMainThread(to: \.priceInput, on: viewModel)
			.store(in: &cancellable)
		
		//MARK: output
		viewModel.isVaild
			.sinkOnMainThread(receiveValue: { _ in
				// 임시
			})
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
			$0.setTitleColor(R.Color.black, for: .normal)
			$0.setTitleColor(R.Color.black.withAlphaComponent(0.7), for: .highlighted)
			$0.contentHorizontalAlignment = .right
			$0.titleLabel?.font = R.Font.title3
			$0.contentEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10) // touch 영역 늘리기
		}
		
		priceTextField = priceTextField.then {
			$0.placeholder = "만원 단위로 입력"
			$0.font = R.Font.h2
			$0.textColor = R.Color.gray900
			$0.keyboardType = .numberPad // 숫자 키보드
			$0.tintColor = R.Color.gray400 // cursor color
			$0.setClearButton(with: R.Icon.cancel, mode: .whileEditing) // clear 버튼
			$0.setNumberMode(unit: "만원") // 단위 설정
			$0.becomeFirstResponder()
		}
	}
	
	private func setLayout() {
		view.addSubviews(stackView, priceTextField)
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
	}
}
