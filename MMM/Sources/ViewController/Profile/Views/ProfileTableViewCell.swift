//
//  ProfileTableViewCell.swift
//  MMM
//
//  Created by geonhyeong on 2023/03/29.
//

import Then
import SnapKit

final class ProfileTableViewCell: UITableViewCell {
	// MARK: - UI Components
	private lazy var contentLabel = UILabel()
	private lazy var navImage = UIImageView()
	private lazy var separator = UIView()

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setup()		// 초기 셋업할 코드들
	}
	
	// Compile time에 error를 발생시키는 코드
	@available(*, unavailable)
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
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
	
	func isNavigationHidden() {
		navImage.isHidden = true
	}
}
//MARK: - Style & Layouts
private extension ProfileTableViewCell {
	// 초기 셋업할 코드들
	private func setup() {
		setAttribute()
		setLayout()
	}
	
	private func setAttribute() {
		
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
	
	private func setLayout() {
		addSubviews(contentLabel, navImage, separator)
		
		contentLabel.snp.makeConstraints {
			$0.leading.equalToSuperview().inset(28)
			$0.trailing.lessThanOrEqualTo(navImage.snp.leading)
			$0.centerY.equalToSuperview()
		}
		
		navImage.snp.makeConstraints {
			$0.trailing.equalToSuperview().inset(28)
			$0.centerY.equalToSuperview()
		}
		
		separator.snp.makeConstraints {
			$0.leading.trailing.equalToSuperview().inset(20)
			$0.bottom.equalToSuperview()
			$0.height.equalTo(1)
		}
	}
}
