//
//  HomeEmptyView.swift
//  MMM
//
//  Created by geonhyeong on 2023/05/02.
//

import UIKit
import Then
import SnapKit

final class HomeEmptyView: UIView {
	// MARK: - Properties
	// MARK: - UI Components
	private lazy var stackView = UIStackView() // imageView, label
	private lazy var ivEmpty = UIImageView()
	private lazy var titleLabel = UILabel()

	override init(frame: CGRect) {
		super.init(frame: frame)
		setup() // 초기 셋업할 코드들
	}
	
	// Compile time에 error를 발생시키는 코드
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
//MARK: - Attribute & Hierarchy & Layouts
private extension HomeEmptyView {
	// 초기 셋업할 코드들
	private func setup() {
		setAttribute()
		setLayout()
	}
	
	private func setAttribute() {
		stackView = stackView.then {
			$0.axis = .vertical
			$0.alignment = .center
			$0.spacing = 16
			$0.distribution = .equalSpacing
		}
		
		ivEmpty = ivEmpty.then {
			$0.image = R.Icon.empty144
			$0.contentMode = .scaleAspectFill
		}
		
		titleLabel = titleLabel.then {
			let attrString = NSMutableAttributedString(string: "아직 아무것도 없어요\n시작하면 통장에 돈이 쌓일지도?")
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.lineSpacing = 2
			attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
			$0.attributedText = attrString
			$0.font = R.Font.prtendard(family: .medium, size: 14)
			$0.textColor = R.Color.gray500
			$0.textAlignment = .center
			$0.numberOfLines = 2
		}
	}
	
	private func setLayout() {
		addSubviews(stackView)
		stackView.addArrangedSubviews(ivEmpty, titleLabel)
		
		ivEmpty.snp.makeConstraints {
			$0.width.equalTo(144)
		}
		
		stackView.snp.makeConstraints {
			$0.centerX.centerY.equalToSuperview()
		}
	}
}
