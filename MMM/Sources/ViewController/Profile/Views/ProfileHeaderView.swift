//
//  ProfileHeaderView.swift
//  MMM
//
//  Created by geonhyeong on 2023/03/29.
//

import UIKit
import Then
import SnapKit

final class ProfileHeaderView: UIView {
	// MARK: - Properties
	// MARK: - UI Components
	private lazy var imageView = UIImageView()
	private lazy var navigationLabel = UILabel()
	private lazy var phrasesLabel = UILabel()
	private lazy var emailLabel = UILabel()
	private lazy var bottomArea = UIView()
	
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
//MARK: - Action
extension ProfileHeaderView {
	// 외부에서 설정
	func setData(email: String) {
		phrasesLabel.text = "오늘도 화이팅!"
		emailLabel.text = email
	}
}
//MARK: - Style & Layouts
private extension ProfileHeaderView {
	// 초기 셋업할 코드들
	private func setup() {
		setAttribute()
		setLayout()
	}
	
	private func setAttribute() {
		// [view]
		backgroundColor = R.Color.gray900

		imageView = imageView.then {
			$0.contentMode = .scaleAspectFill
			$0.layer.masksToBounds = true
			$0.image = R.Icon.mypageBg
		}
		
		navigationLabel = navigationLabel.then {
			$0.text = "마이페이지"
			$0.font = R.Font.h2
			$0.textColor = R.Color.gray200
			$0.textAlignment = .center
		}
		
		phrasesLabel = phrasesLabel.then {
			$0.font = R.Font.h2
			$0.textColor = R.Color.gray200
			$0.textAlignment = .center
		}
		
		emailLabel = emailLabel.then {
			$0.font = R.Font.body3
			$0.textColor = R.Color.gray400
			$0.numberOfLines = 0
			$0.textAlignment = .center
			$0.lineBreakMode = .byCharWrapping
		}
		
		bottomArea = bottomArea.then {
			$0.backgroundColor = .red
		}
	}
	
	private func setLayout() {
		addSubviews(imageView, bottomArea)
		imageView.addSubviews(navigationLabel, phrasesLabel, emailLabel)
		
		imageView.snp.makeConstraints {
			$0.top.equalToSuperview()
			$0.left.right.equalToSuperview()
			$0.height.width.equalToSuperview()
		}
		
		navigationLabel.snp.makeConstraints {
			$0.top.equalToSuperview().inset(19)
			$0.left.equalToSuperview().inset(24)
		}
		
		phrasesLabel.snp.makeConstraints {
			$0.left.equalToSuperview().inset(24)
		}
		
		emailLabel.snp.makeConstraints {
			$0.top.equalTo(phrasesLabel.snp.bottom).offset(4)
			$0.left.equalToSuperview().inset(24)
			$0.bottom.equalToSuperview().inset(24)
		}
	}
}
