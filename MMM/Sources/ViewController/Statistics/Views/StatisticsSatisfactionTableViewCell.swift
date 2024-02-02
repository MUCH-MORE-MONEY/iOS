//
//  StatisticsSatisfactionTableViewCell.swift
//  MMM
//
//  Created by geonhyeong on 2023/08/23.
//

import Then
import SnapKit
import UIKit

// 상속하지 않으려면 final 꼭 붙이기
final class StatisticsSatisfactionTableViewCell: BaseTableViewCell {
	// MARK: - Constants
	private enum UI {
		static let sideMargin: CGFloat = 20
	}
	
	// MARK: - Properties
	private var satisfaction: Satisfaction = .low
	
	// MARK: - UI Components
	private lazy var starImageView = UIImageView()	// ⭐️
	private lazy var scoreLabel = UILabel()
	lazy var titleLabel = UILabel()
	private lazy var checkImageView = UIImageView()	// ✓
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		checkImageView.image = selected ? R.Icon.checkOrange24 : R.Icon.checkGray24
	}
}
//MARK: - Action
extension StatisticsSatisfactionTableViewCell {
	// 외부에서 설정
	func setData(satisfaction: Satisfaction) {
		self.satisfaction = satisfaction
		self.titleLabel.text = satisfaction.title
		self.scoreLabel.text = satisfaction.score
	}
	
	func setSelect(isSelect: Bool) {
		self.checkImageView.image = isSelect ? R.Icon.checkOrange24 : R.Icon.checkGray24
	}
	
	func getSatisfaction() -> Satisfaction {
		return satisfaction
	}
}
//MARK: - Attribute & Hierarchy & Layouts
extension StatisticsSatisfactionTableViewCell {
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()
		
		starImageView = starImageView.then {
			$0.image = R.Icon.iconStarOrange36
			$0.contentMode = .scaleAspectFill
		}
		
		scoreLabel = scoreLabel.then {
			$0.font = R.Font.prtendard(family: .medium, size: 14)
			$0.textColor = R.Color.orange500
			$0.textAlignment = .left
			$0.numberOfLines = 1
		}
		
		titleLabel = titleLabel.then {
			$0.font = R.Font.prtendard(family: .medium, size: 16)
			$0.textColor = R.Color.black
			$0.textAlignment = .left
			$0.numberOfLines = 1
		}
		
		checkImageView = checkImageView.then {
			$0.image = R.Icon.checkGray24
			$0.contentMode = .scaleAspectFit
		}
	}
	
	override func setHierarchy() {
		super.setHierarchy()
		
		contentView.addSubviews(starImageView, scoreLabel, titleLabel, checkImageView)
	}
	
	override func setLayout() {
		super.setLayout()
		
		starImageView.snp.makeConstraints {
			$0.leading.equalToSuperview().inset(UI.sideMargin)
			$0.centerY.equalToSuperview()
		}
		
		scoreLabel.snp.makeConstraints {
			$0.leading.equalTo(starImageView.snp.trailing)
			$0.centerY.equalToSuperview()
		}
		
		titleLabel.snp.makeConstraints {
			$0.leading.equalToSuperview().inset(87)
			$0.centerY.equalToSuperview()
		}
		
		checkImageView.snp.makeConstraints {
			$0.trailing.equalToSuperview().inset(28)
			$0.centerY.equalToSuperview()
		}
	}
}
