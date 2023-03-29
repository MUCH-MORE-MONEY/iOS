//
//  ProfileTableViewCell.swift
//  MMM
//
//  Created by geonhyeong on 2023/03/29.
//

import UIKit

final class ProfileTableViewCell: UITableViewCell {

	private lazy var contentLabel = UILabel().then {
		$0.font = R.Font.body2
		$0.textColor = R.Color.gray900
		$0.textAlignment = .left
	}
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setLayout()
		
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
			
	private func setLayout() {
		addSubviews(contentLabel)
		
		contentLabel.snp.makeConstraints {
			$0.left.right.equalTo(24)
			$0.centerY.equalToSuperview()
		}
	}
}

extension ProfileTableViewCell {
	func setUp(text: String) {
		contentLabel.text = text
	}
}
