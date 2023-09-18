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
	// MARK: - Properties
	// MARK: - UI Components
	private lazy var stackView = UIStackView()
	private lazy var titleLabel = UILabel()
	private lazy var moneyLabel = UILabel()
	
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
//MARK: - Action
extension HomeHeaderStackView {
	// 외부에서 설정
	func setData(isEarn: Bool, money: Int) {
		titleLabel.text = isEarn ? "수익" : "지출"
		titleLabel.textColor = isEarn ?  R.Color.blue500 : R.Color.orange500
		moneyLabel.text = money.withCommas()
	}
}
//MARK: - Attribute & Hierarchy & Layouts
private extension HomeHeaderStackView {
	// 초기 셋업할 코드들
	private func setup() {
		setAttribute()
		setLayout()
	}
	
	private func setAttribute() {
		// [view]
		backgroundColor = R.Color.gray900
		
		stackView = stackView.then {
			$0.axis = .horizontal
			$0.spacing = 8
			$0.alignment = .leading
		}
		
		titleLabel = titleLabel.then {
			$0.text = "지출" // 지출/수익
			$0.font = R.Font.body3
			$0.textColor = R.Color.orange500 // orange500/blue500
			$0.textAlignment = .left
		}
		
		moneyLabel = moneyLabel.then {
			$0.font = R.Font.title3
			$0.textColor = R.Color.gray200
			$0.textAlignment = .left
		}
	}
	
	private func setLayout() {
		stackView.addArrangedSubviews(titleLabel, moneyLabel)
		addSubview(stackView)
				
		stackView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
	}
}
