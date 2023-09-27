//
//  CategoryEditSectionFooter.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/24.
//

import UIKit
import Then
import SnapKit

// 상속하지 않으려면 final 꼭 붙이기
final class CategoryEditSectionFooter: BaseCollectionReusableView {
	// MARK: - Constants
	
	// MARK: - UI Components
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.backgroundColor = R.Color.gray800
	}

	override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
		self.frame = layoutAttributes.frame
	}
	
	func bind(reactor: CategoryReactor) {
		bindState(reactor)
		bindAction(reactor)
	}
}
//MARK: - Action
extension CategoryEditSectionFooter {
	// MARK: 데이터 변경 요청 및 버튼 클릭시 요청 로직(View -> Reactor)
	private func bindAction(_ reactor: CategoryReactor) {
	}
	
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: CategoryReactor) {
	}
}
//MARK: - Bind
extension CategoryEditSectionFooter {
	func setData(isLast: Bool = false) {
		self.isHidden = isLast
	}
}
//MARK: - Action
extension CategoryEditSectionFooter {
}
//MARK: - Attribute & Hierarchy & Layouts
extension CategoryEditSectionFooter {
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()
		
	}
	
	override func setHierarchy() {
		super.setHierarchy()
		
	}
	
	override func setLayout() {
		super.setLayout()
		
	}
}
