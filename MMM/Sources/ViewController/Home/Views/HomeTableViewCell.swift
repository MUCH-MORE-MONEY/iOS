//
//  HomeTableViewCell.swift
//  MMM
//
//  Created by geonhyeong on 2023/04/18.
//

import UIKit

class HomeTableViewCell: UITableViewCell {

	private lazy var contentLabel = UILabel().then {
		$0.font = R.Font.body2
		$0.textColor = R.Color.gray900
		$0.textAlignment = .left
	}
	
	private lazy var navImage = UIImageView().then {
		$0.image = R.Icon.arrowNext16
		$0.contentMode = .scaleAspectFit
	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setLayout()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setLayout() {
		addSubviews(contentLabel, navImage)
		
		contentLabel.snp.makeConstraints {
			$0.leading.equalToSuperview().inset(28)
			$0.trailing.greaterThanOrEqualTo(navImage.snp.leading)
			$0.centerY.equalToSuperview()
		}
		
		
	}
}

extension HomeTableViewCell {
	func setUp(text: String) {
		contentLabel.text = text
	}
}
