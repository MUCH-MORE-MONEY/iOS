//
//  StatisticsAverageView.swift
//  MMM
//
//  Created by geonhyeong on 2023/08/21.
//

import Then
import SnapKit
import UIKit

// 상속하지 않으려면 final 꼭 붙이기
final class StatisticsAverageView: BaseView {
	typealias Reactor = StatisticsReactor

	// MARK: - Constants
	private enum UI {
		static let sideMargin: CGFloat = 20
		static let starLeading: CGFloat = 4
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
	
	func isLoading(_ isLoading: Bool) {
		titleLabel.isHidden = isLoading
		satisfactionLabel.isHidden = isLoading
		starImageView.isHidden = isLoading
	}
}
//MARK: - Attribute & Hierarchy & Layouts
extension StatisticsAverageView {
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()
		
		backgroundColor = R.Color.black
		layer.cornerRadius = 10
		
		starImageView = starImageView.then {
			$0.image = R.Icon.iconStarYellow24
			$0.contentMode = .scaleAspectFit
		}
		
		satisfactionLabel = satisfactionLabel.then {
			$0.text = "0.0점"
			$0.font = R.Font.prtendard(family: .bold, size: 18)
			$0.textColor = R.Color.white
		}
		
		titleLabel = titleLabel.then {
			$0.text = "경제활동 만족도"
			$0.font = R.Font.body3
			$0.textColor = R.Color.white
		}
	}
	
	override func setHierarchy() {
		super.setHierarchy()
		
		addSubviews(starImageView, satisfactionLabel, titleLabel)
	}
	
	override func setLayout() {
		super.setLayout()
		
		starImageView.snp.makeConstraints {
			$0.centerY.equalToSuperview()
			$0.leading.equalToSuperview().inset(UI.sideMargin)
		}
		
		satisfactionLabel.snp.makeConstraints {
			$0.centerY.equalToSuperview()
			$0.leading.equalTo(starImageView.snp.trailing).offset(8)
		}
		
		titleLabel.snp.makeConstraints {
			$0.centerY.equalToSuperview()
			$0.leading.equalTo(satisfactionLabel.snp.trailing).offset(8)
		}
	}
}
