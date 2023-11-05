//
//  CategoryEmptyView.swift
//  MMM
//
//  Created by geonhyeong on 11/3/23.
//

import UIKit
import Then
import SnapKit

final class CategoryEmptyView: BaseView {
	// MARK: - Properties
	// MARK: - UI Components
	private lazy var stackView = UIStackView() // imageView, label
	private lazy var ivEmpty = UIImageView()
	private lazy var titleLabel = UILabel()
}
//MARK: - Attribute & Hierarchy & Layouts
extension CategoryEmptyView {
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()
		
		stackView = stackView.then {
			$0.axis = .vertical
			$0.alignment = .center
			$0.spacing = 16
			$0.distribution = .equalSpacing
		}
		
		ivEmpty = ivEmpty.then {
			$0.image = R.Icon.empty02
			$0.contentMode = .scaleAspectFill
		}
		
		titleLabel = titleLabel.then {
			let attrString = NSMutableAttributedString(string: "선택할 수 있는 카테고리가 없어요.\n관리 페이지에서 추가해주세요!")
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.lineSpacing = 4
			attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
			$0.attributedText = attrString
			$0.font = R.Font.prtendard(family: .medium, size: 14)
			$0.textColor = R.Color.gray500
			$0.textAlignment = .center
			$0.numberOfLines = 2
		}
	}
	
	override func setHierarchy() {
		super.setHierarchy()
		
		addSubviews(stackView)
		stackView.addArrangedSubviews(ivEmpty, titleLabel)
	}
	
	override func setLayout() {
		super.setLayout()
				
		ivEmpty.snp.makeConstraints {
			$0.width.equalTo(144)
		}
		
		stackView.snp.makeConstraints {
			$0.centerX.centerY.equalToSuperview()
		}
	}
}
