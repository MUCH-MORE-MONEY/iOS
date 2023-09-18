//
//  StatisticsSatisfactionView.swift
//  MMM
//
//  Created by geonhyeong on 2023/08/21.
//

import Then
import SnapKit

final class StatisticsSatisfactionView: UIView {
	// MARK: - UI Components
	private lazy var titleLabel = UILabel() // 이번 달 경제활동 만족도
	private lazy var satisfactionLabel = UILabel()
	private lazy var starImageView = UIImageView() // ⭐️

	override init(frame: CGRect) {
		super.init(frame: frame)
		setup() // 초기 셋업할 코드들
	}
	
	// Compile time에 error를 발생시키는 코드
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
//MARK: - Attribute & Hierarchy & Layouts
private extension StatisticsSatisfactionView {
	// 초기 셋업할 코드들
	private func setup() {
		setAttribute()
		setLayout()
	}
	
	private func setAttribute() {
		backgroundColor = R.Color.black
		layer.cornerRadius = 10
		
		titleLabel = titleLabel.then {
			$0.text = "이번 달 경제활동 만족도"
			$0.font = R.Font.prtendard(family: .medium, size: 20)
			$0.textColor = R.Color.white
		}
		
		satisfactionLabel = satisfactionLabel.then {
			$0.text = "0.0"
			$0.font = R.Font.prtendard(family: .bold, size: 36)
			$0.textColor = R.Color.orange500
		}
		
		starImageView = starImageView.then {
			$0.image = R.Icon.iconStarYellow24
			$0.contentMode = .scaleAspectFit
		}
	}
	
	private func setLayout() {
		addSubviews(titleLabel, satisfactionLabel, starImageView)

		titleLabel.snp.makeConstraints {
			$0.centerY.equalToSuperview()
			$0.leading.equalToSuperview().inset(20)
		}
		
		satisfactionLabel.snp.makeConstraints {
			$0.centerY.equalToSuperview()
		}
		
		starImageView.snp.makeConstraints {
			$0.centerY.equalToSuperview()
			$0.leading.equalTo(satisfactionLabel.snp.trailing).offset(8)
			$0.trailing.equalToSuperview().inset(20)
		}
	}
}
