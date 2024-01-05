//
//  CategorySectionFooter.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/24.
//

import UIKit
import Then
import SnapKit

// 상속하지 않으려면 final 꼭 붙이기
final class CategorySectionFooter: BaseCollectionReusableView {
	// MARK: - Constants
	
	// MARK: - UI Components
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.backgroundColor = R.Color.gray800
	}

	override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
		self.frame = layoutAttributes.frame
	}
}
//MARK: - Bind
extension CategorySectionFooter {
	func setData(isLast: Bool = false) {
		self.isHidden = isLast
	}
}
//MARK: - Action
extension CategorySectionFooter {
}
//MARK: - Attribute & Hierarchy & Layouts
extension CategorySectionFooter {
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
