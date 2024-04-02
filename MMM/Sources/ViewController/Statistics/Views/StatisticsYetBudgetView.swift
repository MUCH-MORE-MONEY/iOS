//
//  StatisticsYetBudgetView.swift
//  MMM
//
//  Created by geonhyeong on 2/13/24.
//

import Then
import SnapKit
import UIKit

// 상속하지 않으려면 final 꼭 붙이기
final class StatisticsYetBudgetView: BaseView {
	// MARK: - Constants
	private enum UI {
		static let titleLabelTop: CGFloat = 6
	}
	
	// MARK: - UI Components
	private lazy var titleLabel = UILabel()
	private lazy var imageView = UIImageView() // Boost 아이콘

	override func layoutSubviews() {
		super.layoutSubviews()
	}
}
//MARK: - Action
extension StatisticsYetBudgetView {
	// Text 부분적으로 강조 처리
	private func setSubTextColor() -> NSMutableAttributedString {
		let attributedText1 = NSMutableAttributedString(string: "누구나 실천 가능한\n")
		let attributedText2 = NSMutableAttributedString(string: "이번 달 지출 에산 ")
		let attributedText3 = NSMutableAttributedString(string: "설정하기")
		
		// 일반 Text 속성
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineSpacing = 4
		let textAttributes1: [NSAttributedString.Key : Any] = [
			.font: R.Font.title3,
			.foregroundColor: R.Color.white,
			.paragraphStyle: paragraphStyle
		]
		
		// 강조 Text 속성
		let textAttributes2: [NSAttributedString.Key : Any] = [
			.font: R.Font.title3,
			.foregroundColor: R.Color.orange400
		]
		
		attributedText1.addAttributes(textAttributes1, range: NSMakeRange(0, attributedText1.length))
		attributedText2.addAttributes(textAttributes2, range: NSMakeRange(0, attributedText2.length))
		attributedText3.addAttributes(textAttributes1, range: NSMakeRange(0, attributedText3.length))
		
		attributedText1.append(attributedText2)
		attributedText1.append(attributedText3)
		return attributedText1
	}
}
//MARK: - Attribute & Hierarchy & Layouts
extension StatisticsYetBudgetView: SkeletonLoadable {
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()
				
		backgroundColor = R.Color.black
		layer.cornerRadius = 10
		
		titleLabel = titleLabel.then {
			$0.attributedText = setSubTextColor()
			$0.numberOfLines = 2
		}
		
		imageView = imageView.then {
			$0.image = R.Icon.characterBudget
			$0.contentMode = .scaleAspectFit
		}
	}
	
	override func setHierarchy() {
		super.setHierarchy()
		
		addSubviews(titleLabel, imageView)
	}
	
	override func setLayout() {
		super.setLayout()
		
		titleLabel.snp.makeConstraints {
			$0.centerY.equalToSuperview()
			$0.leading.equalToSuperview().inset(20)
		}
		
		imageView.snp.makeConstraints {
			$0.leading.lessThanOrEqualTo(titleLabel.snp.trailing)
			$0.top.bottom.equalToSuperview()
			$0.trailing.equalToSuperview()
		}
	}
}
