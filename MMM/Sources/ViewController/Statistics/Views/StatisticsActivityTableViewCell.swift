//
//  StatisticsActivityTableViewCell.swift
//  MMM
//
//  Created by geonhyeong on 2023/08/24.
//

import SnapKit
import Then

final class StatisticsActivityTableViewCell: UITableViewCell {
	// MARK: - UI Components
	private lazy var titleLabel = UILabel()
	private lazy var priceLabel = UILabel()
	private lazy var typeImageView = UIImageView()	// +, -

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setup() // 초기 셋업할 코드들
	}
	
	// Compile time에 error를 발생시키는 코드
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		fatalError("init(coder:) has not been implemented")
	}
	
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
//MARK: - Style & Layouts
private extension StatisticsActivityTableViewCell {
	// 초기 셋업할 코드들
	private func setup() {
		setAttribute()
		setLayout()
	}
	
	private func setAttribute() {
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
	
	private func setLayout() {
		contentView.addSubviews(titleLabel, typeImageView, priceLabel)
		
		titleLabel.snp.makeConstraints {
			$0.top.equalToSuperview().inset(2)
			$0.leading.equalToSuperview()
		}
		
		typeImageView.snp.makeConstraints {
			$0.top.equalTo(titleLabel.snp.bottom).offset(8)
			$0.leading.equalToSuperview()
		}
		
		priceLabel.snp.makeConstraints {
			$0.centerY.equalTo(typeImageView)
			$0.leading.equalTo(typeImageView.snp.trailing).offset(4)
		}
	}
}
