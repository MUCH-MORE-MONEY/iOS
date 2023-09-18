//
//  ProfileTableViewCell.swift
//  MMM
//
//  Created by geonhyeong on 2023/03/29.
//

import Then
import SnapKit

// 상속하지 않으려면 final 꼭 붙이기
final class ProfileTableViewCell: BaseTableViewCell {
	// MARK: - Constants
	private enum UI {
		static let contentMargin: UIEdgeInsets = .init(top: 0, left: 24, bottom: 0, right: 24)
		static let separatorMargin: UIEdgeInsets = .init(top: 0, left: 20, bottom: 0, right: 20)
		static let separatorHeight: CGFloat = 1
	}
	
	// MARK: - UI Components
	private lazy var contentLabel = UILabel()
	private lazy var navImage = UIImageView()
	private lazy var separator = UIView()
}
//MARK: - Action
extension ProfileTableViewCell {
	// 외부에서 설정
	func setData(text: String, last: Bool) {
		contentLabel.text = text
		
		DispatchQueue.main.async {
			self.separator.isHidden = last
		}
	}
	
	// Dummy Cell에 필요
	func isNavigationHidden() {
		navImage.isHidden = true
	}
}
//MARK: - Attribute & Hierarchy & Layouts
extension ProfileTableViewCell {
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()
		
		contentLabel = contentLabel.then {
			$0.font = R.Font.body2
			$0.textColor = R.Color.gray900
			$0.textAlignment = .left
		}
		
		navImage = navImage.then {
			$0.image = R.Icon.arrowNext16
			$0.contentMode = .scaleAspectFit
		}
		
		separator = separator.then {
			$0.isHidden = true
			$0.backgroundColor = R.Color.gray200
		}
	}
	
	override func setHierarchy() {
		super.setHierarchy()
		
		addSubviews(contentLabel, navImage, separator)
	}
	
	override func setLayout() {
		super.setLayout()
		
		contentLabel.snp.makeConstraints {
			$0.leading.equalToSuperview().inset(UI.contentMargin.left)
			$0.trailing.lessThanOrEqualTo(navImage.snp.leading)
			$0.centerY.equalToSuperview()
		}
		
		navImage.snp.makeConstraints {
			$0.trailing.equalToSuperview().inset(UI.contentMargin.right)
			$0.centerY.equalToSuperview()
		}
		
		separator.snp.makeConstraints {
			$0.leading.trailing.equalToSuperview().inset(UI.separatorMargin.left)
			$0.bottom.equalToSuperview()
			$0.height.equalTo(UI.separatorHeight)
		}
	}
}
