//
//  CategoryCollectionViewCell.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/16.
//

import UIKit
import ReactorKit

final class CategoryCollectionViewCell: BaseCollectionViewCell, View {
	typealias Reactor = CategoryCollectionViewCellReactor
	// MARK: - Constants
	private enum UI {
		static let segmentedControlHeight: CGFloat = 8
	}
	
	// MARK: - UI Components
	private lazy var titleLabel = UILabel()
	private lazy var priceLabel = UILabel()
	
	override func layoutSubviews() {
		super.layoutSubviews()
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		titleLabel.text = ""
		priceLabel.text = ""
	}
	
	func bind(reactor: CategoryCollectionViewCellReactor) {
		bindState(reactor)
		bindAction(reactor)
	}
}
//MARK: - Action
extension CategoryCollectionViewCell {
}
//MARK: - Bind
extension CategoryCollectionViewCell {
	// MARK: 데이터 변경 요청 및 버튼 클릭시 요청 로직(View -> Reactor)
	private func bindAction(_ reactor: CategoryCollectionViewCellReactor) {
		titleLabel.text = reactor.currentState.category.title
		priceLabel.text = reactor.currentState.category.price
	}
	
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: CategoryCollectionViewCellReactor) {
	}
}
//MARK: - Attribute & Hierarchy & Layouts
extension CategoryCollectionViewCell {
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
		
		contentView.addSubviews(titleLabel, priceLabel)
	}
	
	override func setLayout() {
		super.setLayout()
		
		titleLabel.snp.makeConstraints {
			$0.top.leading.equalToSuperview()
		}
		
		priceLabel.snp.makeConstraints {
			$0.top.equalTo(titleLabel.snp.bottom).offset(UI.priceLabelTopMargin)
			$0.leading.equalToSuperview()
		}
	}
}
