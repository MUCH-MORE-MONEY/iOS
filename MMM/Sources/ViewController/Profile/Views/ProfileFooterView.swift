//
//  ProfileFooterView.swift
//  MMM
//
//  Created by geonhyeong on 2023/03/29.
//

import UIKit

final class ProfileFooterView: UIView {
	
	private lazy var contentLabel = UILabel().then {
		$0.font = R.Font.body2
		$0.textColor = R.Color.gray900
		$0.textAlignment = .left
		$0.text = "앱 버전"
	}
	
	private lazy var versionLabel = UILabel().then {
		$0.font = R.Font.body3
		$0.textColor = R.Color.gray500
		$0.textAlignment = .right
		$0.text = "현재 1.0.0"
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = R.Color.gray900
		setLayout()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
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
