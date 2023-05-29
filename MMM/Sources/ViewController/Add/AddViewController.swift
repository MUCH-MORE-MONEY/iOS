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

final class AddViewController: BaseViewController {
	// MARK: - Properties
	private let viewModel = PriceViewModel()
	private let addViewModel = AddViewModel()
	private lazy var cancellable: Set<AnyCancellable> = .init()

	// MARK: - UI Components
	private lazy var scrollView = UIScrollView()
	private lazy var contentView = UIView()
	private lazy var typeLabel = UILabel()
	
	private lazy var dateLabel = UILabel()
	private lazy var dateButton = UIButton()

	private lazy var priceLabel = UILabel()
	private lazy var priceTextField = UITextField()
	private lazy var warningLabel = UILabel()

	private lazy var nextButton = UIButton()

	public init() {
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
		if let newPosition = priceTextField.position(from: priceTextField.endOfDocument, offset: -1) {
			let newSelectedRange = priceTextField.textRange(from: newPosition, to: newPosition)
			priceTextField.selectedTextRange = newSelectedRange
		}
	}
}
//MARK: - Action
extension AddViewController {
	// MARK: - Private
	// 유무에 따른 attribute 변경
	private func setValid(_ isVaild: Bool) {
		nextButton.isEnabled = isVaild
		warningLabel.isHidden = viewModel.priceInput.isEmpty != isVaild
		
		// shake 에니메이션
		if !viewModel.priceInput.isEmpty && !isVaild {
			priceTextField.shake()
		}
	}
	
	// Set Button Title
	private func setTitle(_ date: Date) {
		dateButton.setTitle(date.getFormattedDate(format: "yyyy년 MM월 dd일"), for: .normal)
	}
	
	// Push Date BottomSheet
	private func didTapDateButton() {
		let picker = DatePickerViewController(viewModel: addViewModel)
		let bottomSheetVC = BottomSheetViewController(contentViewController: picker)
		picker.delegate = bottomSheetVC
		bottomSheetVC.modalPresentationStyle = .overFullScreen
		bottomSheetVC.setSetting(height: 375)
		self.present(bottomSheetVC, animated: false, completion: nil) // fasle(애니메이션 효과로 인해 부자연스럽움 제거)
	}
}
//MARK: - Style & Layouts
private extension AddViewController {
	// 초기 셋업할 코드들
	private func setup() {
		bind()
		setAttribute()
		setLayout()
	}
	
	private func bind() {
		//MARK: input
		priceTextField.textPublisher
			.map{String(Array($0).filter{$0.isNumber})} // 숫자만 추출
			.assignOnMainThread(to: \.priceInput, on: viewModel)
			.store(in: &cancellable)
		
		dateButton.tapPublisher
			.sinkOnMainThread(receiveValue: didTapDateButton)
			.store(in: &cancellable)
		
		//MARK: output
		viewModel.isVaildByWon
			.sinkOnMainThread(receiveValue: setValid)
			.store(in: &cancellable)
		
		// Date Picker
		addViewModel.$date
			.sinkOnMainThread(receiveValue: { [weak self] date in
				self?.setTitle(date)
			}).store(in: &cancellable)
	}
	
	private func setAttribute() {
		// [view]
		view.backgroundColor = R.Color.gray900
		title = "경제활동 추가"

		scrollView = scrollView.then {
			$0.showsVerticalScrollIndicator = false
		}
		
		typeLabel = typeLabel.then {
			$0.text = "이 경제활동의 성격은"
			$0.font = R.Font.title3
			$0.textColor = R.Color.gray200
			$0.textAlignment = .left
			$0.addImageViewOnRight(image: R.Icon.checkOrange24)
		}
		
		dateLabel = dateLabel.then {
			$0.text = "이 경제활동을 한 날짜는"
			$0.font = R.Font.title3
			$0.textColor = R.Color.gray200
			$0.textAlignment = .left
			$0.addImageViewOnRight(image: R.Icon.checkOrange24)
		}
		
		dateButton = dateButton.then {
			setTitle(Date())
			$0.setTitleColor(R.Color.gray100, for: .normal)
			$0.setTitleColor(R.Color.gray100.withAlphaComponent(0.7), for: .highlighted)
			$0.backgroundColor = R.Color.gray900
			$0.titleLabel?.font = R.Font.h2
			$0.contentHorizontalAlignment = .left // 왼쪽 정렬
			$0.setButtonLayer()
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
			$0.setClearButton(with: R.Icon.cancel, mode: .whileEditing) // clear 버튼
			$0.becomeFirstResponder()
		}
		
		warningLabel = warningLabel.then {
			$0.text = "최대 작성 단위을 넘어선 금액이에요"
			$0.font = R.Font.body3
			$0.textColor = R.Color.red500
			$0.textAlignment = .left
			$0.isHidden = true
		}
		
		nextButton = nextButton.then {
			$0.setTitle("다음", for: .normal)
			$0.setTitleColor(R.Color.gray100, for: .normal)
			$0.setTitleColor(R.Color.gray100.withAlphaComponent(0.7), for: .highlighted)
			$0.setBackgroundColor(R.Color.orange500, for: .normal)
			$0.titleLabel?.font = R.Font.title1
			$0.setButtonLayer()
			$0.isEnabled = false
		}
	}
	
	private func setLayout() {
		view.addSubviews(scrollView, nextButton)
		scrollView.addSubview(contentView)
		contentView.addSubviews(typeLabel, dateLabel, dateButton, priceLabel, priceTextField, warningLabel)
		
		scrollView.snp.makeConstraints {
			$0.top.equalTo(view.safeAreaLayoutGuide)
			$0.leading.trailing.equalToSuperview().inset(24)
			$0.bottom.equalTo(view.safeAreaLayoutGuide)
		}
		
		contentView.snp.makeConstraints {
			$0.edges.equalTo(scrollView.contentLayoutGuide)
			$0.width.equalTo(scrollView.frameLayoutGuide)
			$0.height.equalTo(scrollView)
		}
		
		typeLabel.snp.makeConstraints {
			$0.top.equalToSuperview().inset(40)
			$0.leading.trailing.lessThanOrEqualToSuperview()
		}

		dateLabel.snp.makeConstraints {
			$0.top.equalTo(typeLabel.snp.bottom).offset(91)
			$0.leading.trailing.lessThanOrEqualToSuperview()
		}
		
		dateButton.snp.makeConstraints {
			$0.top.equalTo(dateLabel.snp.bottom).offset(20)
			$0.leading.trailing.equalToSuperview()
		}

		priceLabel.snp.makeConstraints {
			$0.top.equalTo(dateButton.snp.bottom).offset(46)
			$0.leading.trailing.lessThanOrEqualToSuperview()
		}

		priceTextField.snp.makeConstraints {
			$0.top.equalTo(priceLabel.snp.bottom).offset(20)
			$0.leading.trailing.equalToSuperview()
		}

		warningLabel.snp.makeConstraints {
			$0.top.equalTo(priceTextField.snp.bottom).offset(8)
			$0.leading.trailing.equalToSuperview()
		}

		nextButton.snp.makeConstraints {
			$0.leading.trailing.equalToSuperview().inset(24)
			$0.bottom.equalToSuperview().inset(40)
			$0.height.equalTo(56)
		}
	}
}
