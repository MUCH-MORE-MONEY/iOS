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

	// MARK: - UI Components
	private lazy var highlightLabel = UILabel()
	private lazy var highlightSwitch = UISwitch()
	private lazy var highlightDescriptionLabel = UILabel()

	private lazy var earnView = HomeFilterView()
	private lazy var payView = HomeFilterView()

    override func viewDidLoad() {
        super.viewDidLoad()
		setup()		// 초기 셋업할 코드들
    }
}

//MARK: - Action
private extension HomeFilterViewController {
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
			.sinkOnMainThread { isOn in
				// 임시: View enable 코드 작성 예정
			}
			.store(in: &cancellable)

		//MARK: output

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
			$0.isOn = true
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
			$0.setup(isEarn: true)
		}
		
		payView = payView.then {
			$0.setup(isEarn: false)
		}
	}
	
	private func setLayout() {
		view.addSubviews(highlightLabel, highlightSwitch, highlightDescriptionLabel, earnView, payView)
		
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
	}
}
