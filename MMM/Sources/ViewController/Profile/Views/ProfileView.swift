//
//  ProfileView.swift
//  MMM
//
//  Created by geonhyeong on 2023/03/29.
//

import UIKit
import Then
import SnapKit

final class ProfileView: UIView {
	
	private lazy var imageView = UIImageView().then {
		$0.contentMode = .scaleAspectFill
		$0.layer.masksToBounds = true
		$0.image = R.Icon.mypageBg
	}
	
	private lazy var navigationLabel = UILabel().then {
		$0.text = "마이페이지"
		$0.font = R.Font.h2
		$0.textColor = R.Color.gray200
		$0.textAlignment = .center
	}
	
	private lazy var phrasesLabel = UILabel().then {
		$0.font = R.Font.h2
		$0.textColor = R.Color.gray200
		$0.textAlignment = .center
	}
	
	private lazy var emailLabel = UILabel().then {
		$0.font = R.Font.body3
		$0.textColor = R.Color.gray400
		$0.numberOfLines = 0
		$0.textAlignment = .center
		$0.lineBreakMode = .byCharWrapping
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
		addSubviews(imageView)
		imageView.addSubviews(navigationLabel, phrasesLabel, emailLabel)
		
		imageView.snp.makeConstraints {
			$0.top.equalToSuperview()
			$0.left.right.equalToSuperview()
			$0.height.width.equalToSuperview()
		}
		
		navigationLabel.snp.makeConstraints {
			$0.top.equalToSuperview().inset(3)
			$0.left.equalToSuperview().inset(24)
		}
		
		phrasesLabel.snp.makeConstraints {
			$0.top.equalToSuperview().inset(144)
			$0.left.equalToSuperview().inset(24)
		}
		
		emailLabel.snp.makeConstraints {
			$0.top.equalTo(phrasesLabel.snp.bottom).offset(4)
			$0.left.equalToSuperview().inset(24)
		}
	}
}

extension ProfileView {
	func setUp(email: String) {
		phrasesLabel.text = "오늘도 화이팅!"
		emailLabel.text = email
	}
}
