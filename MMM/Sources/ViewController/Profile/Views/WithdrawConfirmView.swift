//
//  WithdrawConfirmView.swift
//  MMM
//
//  Created by geonhyeong on 2023/04/05.
//

import UIKit

final class WithdrawConfirmView: UIView {
	
	private lazy var numberLabel = UILabel().then {
		$0.font = R.Font.body4
		$0.textColor = R.Color.white
		$0.textAlignment = .center
		$0.layer.cornerRadius = 10
		$0.clipsToBounds = true
		$0.layer.backgroundColor = R.Color.gray800.cgColor
	}
	
	private lazy var containerStackView = UIStackView().then {
		$0.axis = .vertical
		$0.spacing = 6
		$0.alignment = .leading
	}
	
	private lazy var titleLabel = UILabel().then {
		$0.font = R.Font.body2
		$0.textColor = R.Color.gray900
		$0.textAlignment = .left
	}
	
	private lazy var contentLabel = UILabel().then {
		$0.font = R.Font.body3
		$0.textColor = R.Color.gray800
		$0.textAlignment = .left
		$0.numberOfLines = 0
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setLayout()
	}
	
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setLayout() {
		addSubviews(numberLabel, containerStackView)
				
		[titleLabel, contentLabel].forEach {
			containerStackView.addArrangedSubview($0)
		}
		
		numberLabel.snp.makeConstraints {
			$0.top.left.equalToSuperview()
			$0.width.height.equalTo(20)
		}
		
		containerStackView.snp.makeConstraints {
			$0.left.equalTo(numberLabel.snp.right).offset(8)
			$0.top.equalToSuperview()
			$0.right.equalToSuperview().inset(19)
		}
	}
}

extension WithdrawConfirmView {
	public func setUp(number: String, title:String, content: String) {
		numberLabel.text = number
		titleLabel.text = title
		let attributedString = NSMutableAttributedString(string: content)
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineBreakStrategy = .hangulWordPriority
		paragraphStyle.lineSpacing = 2
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
