//
//  StatisticsActivityTableViewCell.swift
//  MMM
//
//  Created by geonhyeong on 2023/08/24.
//

import UIKit

final class StatisticsActivityTableViewCell: UITableViewCell {
	// MARK: - UI Components

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
	}
}
//MARK: - Action
extension StatisticsActivityTableViewCell {
	// 외부에서 설정
	func setData(data: EconomicActivity, last: Bool) {
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
	}
	
	private func setLayout() {
	}
}
