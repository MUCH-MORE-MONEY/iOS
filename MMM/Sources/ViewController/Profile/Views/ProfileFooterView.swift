//
//  ProfileFooterView.swift
//  MMM
//
//  Created by geonhyeong on 2023/03/29.
//

import UIKit

final class ProfileFooterView: UIView {
	// MARK: - Properties
	// MARK: - UI Components
	private lazy var contentLabel = UILabel()
	private lazy var versionLabel = UILabel()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()		// 초기 셋업할 코드들
	}
	
	// Compile time에 error를 발생시키는 코드
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
//MARK: - Attribute & Hierarchy & Layouts
private extension ProfileFooterView {
	// 초기 셋업할 코드들
	private func setup() {
		setAttribute()
		setLayout()
	}
	
	private func setAttribute() {
		// [view]
		backgroundColor = R.Color.gray900

		contentLabel = contentLabel.then {
			$0.font = R.Font.body2
			$0.textColor = R.Color.gray900
			$0.textAlignment = .left
			$0.text = "앱 버전"
		}
		
		versionLabel = versionLabel.then {
			$0.font = R.Font.body3
			$0.textColor = R.Color.gray500
			$0.textAlignment = .right
			$0.text = "현재 1.0.0"
		}
	}
	
	private func setLayout() {
		addSubviews(contentLabel, versionLabel)
				
		contentLabel.snp.makeConstraints {
			$0.left.equalToSuperview().inset(28)
			$0.top.equalTo(12)
		}
		
		versionLabel.snp.makeConstraints {
			$0.right.equalToSuperview().inset(28)
			$0.top.equalTo(12)
		}
	}
}
