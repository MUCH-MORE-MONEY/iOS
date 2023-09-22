//
//  StatisticsActivityTableViewCell.swift
//  MMM
//
//  Created by geonhyeong on 2023/08/24.
//

import SnapKit
import Then

// 상속하지 않으려면 final 꼭 붙이기
final class StatisticsActivityTableViewCell: BaseTableViewCell {
	
	// MARK: - Constants
	private enum UI {
		static let titleLabelMargin: UIEdgeInsets = .init(top: 2, left: 0, bottom: 0, right: 0)
		static let ivTypeMargin: UIEdgeInsets = .init(top: 8, left: 0, bottom: 0, right: 0)
		static let priceLabelMargin: UIEdgeInsets = .init(top: 0, left: 4, bottom: 0, right: 0)
	}
	
	// MARK: - UI Components
	private lazy var titleLabel = UILabel()
	private lazy var priceLabel = UILabel()
	private lazy var typeImageView = UIImageView()	// +, -
	
	// 재활용 셀 중접오류 해결
	override func prepareForReuse() {
		typeImageView.image = nil
	}
}
//MARK: - Action
extension StatisticsActivityTableViewCell {
	// 외부에서 설정
	func setData(data: EconomicActivity) {
		titleLabel.text = data.title
		priceLabel.text = data.amount.withCommas() + " 원"
		typeImageView.image = data.type == "01" ? R.Icon.plus16 : R.Icon.minus16
	}
}
//MARK: - Attribute & Hierarchy & Layouts
extension StatisticsActivityTableViewCell {
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()
		
		self.backgroundColor = R.Color.black

		titleLabel = titleLabel.then {
			$0.font = R.Font.title3
			$0.textColor = R.Color.white
			$0.textAlignment = .left
			$0.numberOfLines = 1
		}
		
		typeImageView = typeImageView.then {
			$0.contentMode = .scaleAspectFit
		}
		
		priceLabel = priceLabel.then {
			$0.font = R.Font.body3
			$0.textColor = R.Color.white
			$0.textAlignment = .left
			$0.numberOfLines = 1
		}
	}
	
	override func setHierarchy() {
		super.setHierarchy()
		
		contentView.addSubviews(titleLabel, typeImageView, priceLabel)
	}
	
	override func setLayout() {
		super.setLayout()
		
		titleLabel.snp.makeConstraints {
			$0.top.equalToSuperview().inset(UI.titleLabelMargin.top)
			$0.leading.trailing.equalToSuperview()
		}
		
		typeImageView.snp.makeConstraints {
			$0.top.equalTo(titleLabel.snp.bottom).offset(UI.ivTypeMargin.top)
			$0.leading.equalToSuperview()
		}
		
		priceLabel.snp.makeConstraints {
			$0.centerY.equalTo(typeImageView)
			$0.leading.equalTo(typeImageView.snp.trailing).offset(UI.priceLabelMargin.left)
			$0.trailing.lessThanOrEqualToSuperview()
		}
	}
}
