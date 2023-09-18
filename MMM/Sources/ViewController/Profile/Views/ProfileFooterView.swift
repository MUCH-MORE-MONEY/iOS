//
//  ProfileFooterView.swift
//  MMM
//
//  Created by geonhyeong on 2023/03/29.
//

import UIKit
import Then
import SnapKit

// 상속하지 않으려면 final 꼭 붙이기
final class ProfileFooterView: BaseView {
	// MARK: - Constants
	private enum UI {
		static let contentMargin: UIEdgeInsets = .init(top: 12, left: 28, bottom: 0, right: 28)
	}
	
	// MARK: - Properties
	
	// MARK: - UI Components
	private lazy var contentLabel = UILabel()
	private lazy var versionLabel = UILabel()
}
//MARK: - Attribute & Hierarchy & Layouts
extension ProfileFooterView {
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()
		
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
	
	override func setHierarchy() {
		super.setHierarchy()
		
		addSubviews(contentLabel, versionLabel)
	}
	
	override func setLayout() {
		super.setLayout()
		
		contentLabel.snp.makeConstraints {
			$0.top.equalTo(UI.contentMargin.top)
			$0.leading.equalToSuperview().inset(UI.contentMargin.left)
		}
		
		versionLabel.snp.makeConstraints {
			$0.top.equalTo(UI.contentMargin.top)
			$0.trailing.equalToSuperview().inset(UI.contentMargin.right)
		}
	}
}
