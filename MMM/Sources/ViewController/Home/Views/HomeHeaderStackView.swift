//
//  HomeHeaderStackView.swift
//  MMM
//
//  Created by geonhyeong on 2023/04/27.
//

import UIKit
import Then
import SnapKit

final class HomeHeaderStackView: UIView {
	
	private lazy var stackView = UIStackView().then {
		$0.axis = .horizontal
		$0.spacing = 8
		$0.alignment = .leading
	}
	
	private lazy var titleLabel = UILabel().then {
		$0.text = "지출" // 지출/수익
		$0.font = R.Font.body3
		$0.textColor = R.Color.orange500 // orange500/blue500
		$0.textAlignment = .left
	}
	
	private lazy var moneyLabel = UILabel().then {
		$0.font = R.Font.title3
		$0.textColor = R.Color.gray200
		$0.textAlignment = .left
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = R.Color.gray900
		setLayout()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setLayout() {
		stackView.addArrangedSubviews(titleLabel, moneyLabel)
		addSubview(stackView)
				
		stackView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
	}
}

extension HomeHeaderStackView {
	func setUp(isEarn: Bool, money: Int) {
		titleLabel.text = isEarn ? "수익" : "지출"
		titleLabel.textColor = isEarn ?  R.Color.blue500 : R.Color.orange500
		moneyLabel.text = money.withCommas()
	}
}
