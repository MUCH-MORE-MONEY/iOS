//
//  CategoryEditEmptyView.swift
//  MMM
//
//  Created by geonhyeong on 11/5/23.
//

import UIKit
import Then
import SnapKit
import ReactorKit

final class CategoryEditEmptyView: BaseView {
	// MARK: - Properties
	// MARK: - UI Components
	private lazy var stackView = UIStackView() // imageView, label
	private lazy var ivEmpty = UIImageView()
	private lazy var titleLabel = UILabel()
	private lazy var addButton = UIButton()
}
//MARK: - Bind
extension CategoryEditEmptyView {
}
//MARK: - Attribute & Hierarchy & Layouts
extension CategoryEditEmptyView {
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()
		
		stackView = stackView.then {
			$0.axis = .vertical
			$0.alignment = .center
			$0.spacing = 20
			$0.distribution = .equalSpacing
		}
		
		ivEmpty = ivEmpty.then {
			$0.image = R.Icon.empty02
			$0.contentMode = .scaleAspectFill
		}
		
		titleLabel = titleLabel.then {
			let attrString = NSMutableAttributedString(string: "카테고리 유형을 편집해\n내 경제활동에 맞춰 카테고리를 정리하세요")
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.lineSpacing = 4
			attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
			$0.attributedText = attrString
			$0.font = R.Font.prtendard(family: .medium, size: 14)
			$0.textColor = R.Color.gray400
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
			$0.verticalEdges.equalToSuperview()
			$0.horizontalEdges.equalToSuperview().inset(65)
		}
	}
}
