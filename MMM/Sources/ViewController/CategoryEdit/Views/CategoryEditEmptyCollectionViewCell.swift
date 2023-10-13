//
//  CategoryEditEmptyCollectionViewCell.swift
//  MMM
//
//  Created by geonhyeong on 10/13/23.
//

import UIKit
import Then
import SnapKit
import ReactorKit

// 상속하지 않으려면 final 꼭 붙이기
final class CategoryEditEmptyCollectionViewCell: BaseCollectionViewCell {
	// MARK: - Constants
	private enum UI {
	}
		
	// MARK: - UI Components
	private lazy var titleLabel = UILabel()
	
	override func layoutSubviews() {
		super.layoutSubviews()
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
//		titleLabel.text = ""
	}
}
//MARK: - Bind
extension CategoryEditEmptyCollectionViewCell {
}
//MARK: - Action
extension CategoryEditEmptyCollectionViewCell {
}
//MARK: - Attribute & Hierarchy & Layouts
extension CategoryEditEmptyCollectionViewCell {
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()
		
		backgroundColor = R.Color.gray900
		
		titleLabel = titleLabel.then {
			$0.text = "카테고리를 추가해주세요"
			$0.font = R.Font.body1
			$0.textColor = R.Color.gray500
			$0.textAlignment = .left
		}
	}
	
	override func setHierarchy() {
		super.setHierarchy()
		
		contentView.addSubviews(titleLabel)
	}
	
	override func setLayout() {
		super.setLayout()
		
		titleLabel.snp.makeConstraints {
			$0.horizontalEdges.equalToSuperview()
			$0.centerY.equalToSuperview()
		}
	}
}
