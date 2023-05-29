//
//  HomeFilterViewController.swift
//  MMM
//
//  Created by geonhyeong on 2023/05/18.
//

import UIKit
import Combine
import Then
import SnapKit

final class HomeFilterViewController: BaseViewController {
	// MARK: - Properties
	private lazy var cancellable: Set<AnyCancellable> = .init()
	private let viewModel: HomeViewModel

	// MARK: - UI Components
	private lazy var highlightLabel = UILabel()
	private lazy var highlightSwitch = UISwitch()
	private lazy var highlightDescriptionLabel = UILabel()

	private lazy var earnView = HomeFilterView()
	private lazy var payView = HomeFilterView()
	
	private lazy var dailyTotalLabel = UILabel()
	private lazy var dailyTotalSwitch = UISwitch()
	private lazy var dailyTotalDescriptionLabel = UILabel()

	init(viewModel: HomeViewModel) {
		self.viewModel = viewModel
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
	
	override func viewWillDisappear(_ animated: Bool) {
		// 한번 click되면 nil이 아니라 modal 되는 문제 해결
		viewModel.didTapHighlightButton = nil
		viewModel.didTapColorButton = nil
	}
}
//MARK: - Action
private extension HomeFilterViewController {
	/// 금액 하이라이트 isEnabled
	func toggleHighlightSwitch(_ isOn: Bool) {
		earnView.toggleEnabled(isOn)
		payView.toggleEnabled(isOn)
		viewModel.isHighlight = !viewModel.isHighlight
	}
	
	/// 일별 금액 합계 isEnabled
	func toggleDailyTotalSwitch(_ isOn: Bool) {
		viewModel.isDailySetting = !viewModel.isDailySetting
	}
	
	// MARK: - Private
	// Push Highlight BottomSheet
	private func didTapHighlightButton(_ isEarn: Bool) {
		let vc = HighlightViewController(homeViewModel: viewModel)
		let bottomSheetVC = BottomSheetViewController(contentViewController: vc)
		vc.delegate = bottomSheetVC
		vc.setData(isEarn: isEarn)
		bottomSheetVC.modalPresentationStyle = .overFullScreen
		bottomSheetVC.setSetting(height: 174, isDrag: false)
		self.present(bottomSheetVC, animated: false, completion: nil) // fasle(애니메이션 효과로 인해 부자연스럽움 제거)
	}
}
//MARK: - Style & Layouts
private extension HomeFilterViewController {
	// 초기 셋업할 코드들
	private func setup() {
		bind()
		setAttribute()
		setLayout()
	}
	
	private func bind() {
		//MARK: input
		highlightSwitch.statePublisher
			.sinkOnMainThread(receiveValue: toggleHighlightSwitch)
			.store(in: &cancellable)
		
		dailyTotalSwitch.statePublisher
			.sinkOnMainThread(receiveValue: toggleDailyTotalSwitch)
			.store(in: &cancellable)

		//MARK: output
		viewModel.$didTapHighlightButton
			.sinkOnMainThread(receiveValue: { value in
				guard let value = value else { return }
				self.didTapHighlightButton(value)
			}).store(in: &cancellable)
		
		// 수입
		viewModel.$earnStandard
			.sinkOnMainThread(receiveValue: { value in
				self.earnView.setData(price: value)
			}).store(in: &cancellable)
		
		// 지출
		viewModel.$payStandard
			.sinkOnMainThread(receiveValue: { value in
				self.payView.setData(price: value)
			}).store(in: &cancellable)
	}
	
	private func setAttribute() {
		// [view]
		view.backgroundColor = R.Color.gray100
		title = "달력 관리"
		
		highlightLabel = highlightLabel.then {
			$0.text = "금액 하이라이트 설정"
			$0.font = R.Font.h5
			$0.textColor = R.Color.gray800
		}
		
		highlightSwitch = highlightSwitch.then {
			$0.isOn = viewModel.isHighlight
			$0.onTintColor = R.Color.gray900
		}
		
		highlightDescriptionLabel = highlightDescriptionLabel.then {
			let attrString = NSMutableAttributedString(string: "하루 중 일정 경제활동을 했을 때 달력에 원하는 색깔로 강조해줘요.")
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.lineSpacing = 2
			paragraphStyle.lineBreakMode = .byCharWrapping
			attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
			$0.attributedText = attrString
			$0.font = R.Font.body3
			$0.textColor = R.Color.gray800
			$0.numberOfLines = 0
		}
		
		earnView = earnView.then {
			$0.setData(viewModel: viewModel, isEarn: true)
			$0.toggleEnabled(viewModel.isHighlight)
		}
		
		payView = payView.then {
			$0.setData(viewModel: viewModel, isEarn: false)
			$0.toggleEnabled(viewModel.isHighlight)
		}
		
		dailyTotalLabel = dailyTotalLabel.then {
			$0.text = "일별 금액 합계 설정"
			$0.font = R.Font.h5
			$0.textColor = R.Color.gray800
		}
		
		dailyTotalSwitch = dailyTotalSwitch.then {
			$0.isOn = viewModel.isDailySetting
			$0.onTintColor = R.Color.gray900
		}
		
		dailyTotalDescriptionLabel = dailyTotalDescriptionLabel.then {
			let attrString = NSMutableAttributedString(string: "하루에 기록한 수입과 지출의 총 합계를 달력에 보여줘요.")
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.lineSpacing = 2
			paragraphStyle.lineBreakMode = .byCharWrapping
			attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
			$0.attributedText = attrString
			$0.font = R.Font.body3
			$0.textColor = R.Color.gray800
			$0.numberOfLines = 0
		}
	}
	
	private func setLayout() {
		view.addSubviews(highlightLabel, highlightSwitch, highlightDescriptionLabel, earnView, payView, dailyTotalLabel, dailyTotalSwitch, dailyTotalDescriptionLabel)
		
		highlightLabel.snp.makeConstraints {
			$0.top.leading.equalToSuperview().inset(24)
		}
		
		highlightSwitch.snp.makeConstraints {
			$0.top.trailing.equalToSuperview().inset(24)
		}
		
		highlightDescriptionLabel.snp.makeConstraints {
			$0.top.equalTo(highlightSwitch.snp.bottom).offset(12)
			$0.leading.trailing.equalToSuperview().inset(24)
		}
		
		// 수입 Filter View
		earnView.snp.makeConstraints {
			$0.top.equalTo(highlightDescriptionLabel.snp.bottom).offset(24)
			$0.leading.trailing.equalToSuperview().inset(24)
			$0.height.equalTo(88)
		}
		
		// 지출 Filter View
		payView.snp.makeConstraints {
			$0.top.equalTo(earnView.snp.bottom).offset(12)
			$0.leading.trailing.equalToSuperview().inset(24)
			$0.height.equalTo(88)
		}
		
		dailyTotalLabel.snp.makeConstraints {
			$0.top.equalTo(payView.snp.bottom).offset(48)
			$0.leading.equalToSuperview().inset(24)
		}
		
		dailyTotalSwitch.snp.makeConstraints {
			$0.top.equalTo(payView.snp.bottom).offset(48)
			$0.trailing.equalToSuperview().inset(24)
		}

		dailyTotalDescriptionLabel.snp.makeConstraints {
			$0.top.equalTo(dailyTotalSwitch.snp.bottom).offset(12)
			$0.leading.trailing.equalToSuperview().inset(24)
		}
	}
}
