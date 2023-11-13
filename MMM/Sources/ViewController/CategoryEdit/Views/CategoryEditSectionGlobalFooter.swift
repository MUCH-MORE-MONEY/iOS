//
//  CategorySectionGlobalFooter.swift
//  MMM
//
//  Created by geonhyeong on 11/7/23.
//

import UIKit
import Then
import SnapKit
import ReactorKit

// 상속하지 않으려면 final 꼭 붙이기
final class CategoryEditSectionGlobalFooter: BaseCollectionReusableView, View {
	typealias Reactor = CategoryEditReactor
	
	// MARK: - Constants
	// MARK: - UI Components

	override init(frame: CGRect) {
		super.init(frame: frame)
	}

	override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
		self.frame = layoutAttributes.frame
	}
	
	func bind(reactor: CategoryEditReactor) {
		bindState(reactor)
		bindAction(reactor)
	}
}
//MARK: - Bind
extension CategoryEditSectionGlobalFooter {
	// MARK: 데이터 변경 요청 및 버튼 클릭시 요청 로직(View -> Reactor)
	private func bindAction(_ reactor: CategoryEditReactor) { }
	
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: CategoryEditReactor) { }
}
//MARK: - Action
extension CategoryEditSectionGlobalFooter {
}
//MARK: - Attribute & Hierarchy & Layouts
extension CategoryEditSectionGlobalFooter {
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()
		
		backgroundColor = R.Color.gray900
	}
	
	override func setHierarchy() {
		super.setHierarchy()
	}
	
	override func setLayout() {
		super.setLayout()
	}
}
