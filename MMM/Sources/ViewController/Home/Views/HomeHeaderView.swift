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
	
	private lazy var payView = HomeHeaderStackView()
	private lazy var earnView = HomeHeaderStackView()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = R.Color.gray900
		setLayout()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setLayout() {
		addSubviews(payView, earnView)
				
		payView.snp.makeConstraints {
			$0.centerY.equalToSuperview()
			$0.leading.equalToSuperview().inset(16)
		}
		
		earnView.snp.makeConstraints {
			$0.centerY.equalToSuperview()
			$0.leading.equalTo(payView.snp.trailing).offset(16)
		}
	}
}

extension HomeHeaderView {
	func setUp(pay: Int, earn: Int) {
		payView.setUp(isEarn: false, money: pay)
		earnView.setUp(isEarn: true, money: earn)
	}
}
