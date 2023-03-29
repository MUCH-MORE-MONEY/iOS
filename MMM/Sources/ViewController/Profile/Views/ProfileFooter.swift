//
//  ProfileFooter.swift
//  MMM
//
//  Created by geonhyeong on 2023/03/29.
//

import UIKit

final class ProfileFooter: UIView {
	private lazy var contentLabel = UILabel().then {
		$0.font = R.Font.body2
		$0.textColor = R.Color.gray900
		$0.textAlignment = .left
		$0.text = "앱 버전"
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
		addSubviews(contentLabel)
		
		contentLabel.snp.makeConstraints {
			$0.left.equalToSuperview()
		}
	}
}
