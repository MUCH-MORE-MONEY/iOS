//
//  HomeHeaderView.swift
//  MMM
//
//  Created by geonhyeong on 2023/04/27.
//

import UIKit
import Then
import SnapKit

final class HomeHeaderView: UIView {
	// MARK: - Properties
	// MARK: - UI Components
	private lazy var payView = HomeHeaderStackView()
	private lazy var earnView = HomeHeaderStackView()
	
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
extension HomeHeaderView {
	// 외부에서 설정
	func setUp(pay: Int, earn: Int) {
		payView.setUp(isEarn: false, money: pay)
		earnView.setUp(isEarn: true, money: earn)
	}
}
//MARK: - Style & Layouts
private extension HomeHeaderView {
	// 초기 셋업할 코드들
	private func setup() {
		setAttribute()
		setLayout()
	}
	
	private func setAttribute() {
		// [view]
		backgroundColor = R.Color.gray900
	}
	
	private func setLayout() {
		addSubviews(payView, earnView)
				
		payView.snp.makeConstraints {
			$0.bottom.equalToSuperview().inset(8)
			$0.leading.equalToSuperview().inset(16)
		}
		
		earnView.snp.makeConstraints {
			$0.bottom.equalToSuperview().inset(8)
			$0.leading.equalTo(payView.snp.trailing).offset(16)
		}
	}
}
