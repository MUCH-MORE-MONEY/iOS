//
//  CategorySectionHeader.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/16.
//

import UIKit

final class CategorySectionHeader: BaseCollectionReusableView {
	
	// MARK: - UI Components
	private lazy var titleLabel = UILabel()
	private lazy var priceLabel = UILabel()
	private lazy var typeImageView = UIImageView()
}
//MARK: - Action
extension CategorySectionHeader {
}
//MARK: - Bind
extension CategorySectionHeader {
	// MARK: 데이터 변경 요청 및 버튼 클릭시 요청 로직(View -> Reactor)
	private func bindAction(_ reactor: CategoryReactor) {
	}
	
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: CategoryReactor) {
	}
}
//MARK: - Attribute & Hierarchy & Layouts
extension CategorySectionHeader {
	override func setAttribute() {
		super.setAttribute()
		
		titleLabel = titleLabel.then {
			$0.font = R.Font.body1
			$0.textColor = R.Color.gray100
			$0.textAlignment = .left
		}
		
		priceLabel = priceLabel.then {
			$0.font = R.Font.body3
			$0.textColor = R.Color.gray500
			$0.textAlignment = .left
		}
	}
	
	override func setHierarchy() {
		super.setHierarchy()
		
		addSubviews(typeImageView, titleLabel, priceLabel)
	}
	
	override func setLayout() {
		super.setLayout()
		
		titleLabel.snp.makeConstraints {
			$0.top.leading.equalToSuperview()
		}
		
		priceLabel.snp.makeConstraints {
			$0.top.leading.equalToSuperview()
		}
	}
}
