//
//  WithdrawConfirmView.swift
//  MMM
//
//  Created by geonhyeong on 2023/04/05.
//

import UIKit

final class WithdrawConfirmView: UIView {
	// MARK: - Properties
	// MARK: - UI Components
	private lazy var numberLabel = UILabel()
	private lazy var containerStackView = UIStackView()
	private lazy var titleLabel = UILabel()
	private lazy var contentLabel = UILabel()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()		// 초기 셋업할 코드들
	}
	
	// Compile time에 error를 발생시키는 코드
	@available(*, unavailable)
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
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
//MARK: - Style & Layouts
private extension WithdrawConfirmView {
	// 초기 셋업할 코드들
	private func setup() {
		setAttribute()
		setLayout()
	}
	
	private func setAttribute() {
		
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
	
	private func setLayout() {
		addSubviews(numberLabel, containerStackView)
		containerStackView.addArrangedSubviews(titleLabel, contentLabel)
		
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
