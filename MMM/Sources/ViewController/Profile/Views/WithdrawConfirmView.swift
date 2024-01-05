//
//  WithdrawConfirmView.swift
//  MMM
//
//  Created by geonhyeong on 2023/04/05.
//

import UIKit
import Then
import SnapKit

// 상속하지 않으려면 final 꼭 붙이기
final class WithdrawConfirmView: BaseView {
	// MARK: - Constants
	private enum UI {
		static let numberLabelWidth: CGFloat = 20
		static let stackViewMargin: UIEdgeInsets = .init(top: 0, left: 8, bottom: 0, right: 0)
	}
	
	// MARK: - Properties
	
	// MARK: - UI Components
	private lazy var numberLabel = UILabel()
	private lazy var containerStackView = UIStackView()
	private lazy var titleLabel = UILabel()
	private lazy var contentLabel = UILabel()
}
//MARK: - Action
extension WithdrawConfirmView {
	// 외부에서 설정
	public func setData(number: String, title:String, content: String) {
		numberLabel.text = number
		titleLabel.text = title
		let attributedString = NSMutableAttributedString(string: content)
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineBreakStrategy = .hangulWordPriority
		paragraphStyle.lineSpacing = 3
		paragraphStyle.alignment = .left
		
		let textAttributes: [NSAttributedString.Key : Any] = [
			NSAttributedString.Key.font: R.Font.body3,
			NSAttributedString.Key.foregroundColor: R.Color.gray800,
			NSAttributedString.Key.paragraphStyle: paragraphStyle
		]
		
		attributedString.addAttributes(textAttributes, range: NSMakeRange(0, attributedString.length))
		contentLabel.attributedText = attributedString
	}
}
//MARK: - Attribute & Hierarchy & Layouts
extension WithdrawConfirmView {
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()
		
		numberLabel = numberLabel.then {
			$0.font = R.Font.body4
			$0.textColor = R.Color.white
			$0.textAlignment = .center
			$0.layer.cornerRadius = 10
			$0.clipsToBounds = true
			$0.layer.backgroundColor = R.Color.gray800.cgColor
		}
		
		containerStackView = containerStackView.then {
			$0.axis = .vertical
			$0.spacing = 6
			$0.alignment = .leading
		}
		
		titleLabel = titleLabel.then {
			$0.font = R.Font.body2
			$0.textColor = R.Color.gray900
			$0.textAlignment = .left
		}
		
		contentLabel = contentLabel.then {
			$0.font = R.Font.body3
			$0.textColor = R.Color.gray800
			$0.textAlignment = .left
			$0.numberOfLines = 0
		}
	}
	
	override func setHierarchy() {
		super.setHierarchy()
		
		addSubviews(numberLabel, containerStackView)
		containerStackView.addArrangedSubviews(titleLabel, contentLabel)
	}
	
	override func setLayout() {
		super.setLayout()
		
		numberLabel.snp.makeConstraints {
			$0.top.leading.equalToSuperview()
			$0.width.height.equalTo(UI.numberLabelWidth)
		}
		
		containerStackView.snp.makeConstraints {
			$0.top.equalToSuperview()
			$0.leading.equalTo(numberLabel.snp.trailing).offset(UI.stackViewMargin.left)
			$0.trailing.equalToSuperview()
		}
	}
}
