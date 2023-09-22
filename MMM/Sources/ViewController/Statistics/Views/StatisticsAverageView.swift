//
//  StatisticsAverageView.swift
//  MMM
//
//  Created by geonhyeong on 2023/08/21.
//

import Then
import SnapKit

// 상속하지 않으려면 final 꼭 붙이기
final class StatisticsAverageView: BaseView {
	typealias Reactor = StatisticsReactor

	// MARK: - Constants
	private enum UI {
		static let sideMargin: CGFloat = 20
		static let starLeading: CGFloat = 8
	}
	
	// MARK: - UI Components
	private lazy var titleLabel = UILabel() // 이번 달 경제활동 만족도
	private lazy var satisfactionLabel = UILabel()
	private lazy var starImageView = UIImageView() // ⭐️
}
//MARK: - Action
extension StatisticsAverageView {
	// 외부에서 설정
	func setData(average: Double) {
		satisfactionLabel.text = String(average)
	}
}
//MARK: - Attribute & Hierarchy & Layouts
extension StatisticsAverageView {
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()
		
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
	
	override func setHierarchy() {
		super.setHierarchy()
		
		addSubviews(titleLabel, satisfactionLabel, starImageView)
	}
	
	override func setLayout() {
		super.setLayout()
		
		titleLabel.snp.makeConstraints {
			$0.centerY.equalToSuperview()
			$0.leading.equalToSuperview().inset(UI.sideMargin)
		}
		
		satisfactionLabel.snp.makeConstraints {
			$0.centerY.equalToSuperview()
		}
		
		starImageView.snp.makeConstraints {
			$0.centerY.equalToSuperview()
			$0.leading.equalTo(satisfactionLabel.snp.trailing).offset(UI.starLeading)
			$0.trailing.equalToSuperview().inset(UI.sideMargin)
		}
	}
}
