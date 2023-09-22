//
//  ProfileHeaderView.swift
//  MMM
//
//  Created by geonhyeong on 2023/03/29.
//

import UIKit
import Then
import SnapKit

// 상속하지 않으려면 final 꼭 붙이기
final class ProfileHeaderView: BaseView {
	// MARK: - Constants
	private enum UI {
		static let contentMargin: UIEdgeInsets = .init(top: 4, left: 24, bottom: 24, right: 24)
		static let emailLabelMargin: UIEdgeInsets = .init(top: 4, left: 24, bottom: 24, right: 24)
	}
	
	// MARK: - Properties
	
	// MARK: - UI Components
	private lazy var imageView = UIImageView()
	private lazy var phrasesLabel = UILabel()
	private lazy var emailLabel = UILabel()
	private lazy var bottomArea = UIView()
}
//MARK: - Action
extension ProfileHeaderView {
	// 외부에서 설정
	func setData(email: String) {
		phrasesLabel.text = "오늘도 화이팅!"
		emailLabel.text = email
	}
}
//MARK: - Attribute & Hierarchy & Layouts
extension ProfileHeaderView {
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()
		
		// [view]
		backgroundColor = R.Color.gray900

		imageView = imageView.then {
			$0.contentMode = .scaleAspectFit
			$0.layer.masksToBounds = true
			$0.image = R.Icon.mypageBg
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
	
	override func setHierarchy() {
		super.setHierarchy()
		
		addSubviews(imageView, bottomArea)
		imageView.addSubviews(phrasesLabel, emailLabel)
	}
	
	override func setLayout() {
		super.setLayout()
		
		imageView.snp.makeConstraints {
			$0.leading.bottom.equalToSuperview()
		}
		
		phrasesLabel.snp.makeConstraints {
			$0.leading.equalToSuperview().inset(UI.contentMargin.left)
		}
		
		emailLabel.snp.makeConstraints {
			$0.top.equalTo(phrasesLabel.snp.bottom).offset(UI.emailLabelMargin.top)
			$0.leading.equalToSuperview().inset(UI.contentMargin.left)
			$0.bottom.equalToSuperview().inset(UI.contentMargin.bottom)
		}
	}
}
