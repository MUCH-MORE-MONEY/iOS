//
//  SatisfactionTableViewCell.swift
//  MMM
//
//  Created by geonhyeong on 2023/08/23.
//

import UIKit

final class SatisfactionTableViewCell: UITableViewCell {
	// MARK: - UI Components
	private lazy var starImageView = UIImageView()	// ⭐️
	private lazy var scoreLabel = UILabel()
	private lazy var titleLabel = UILabel()
	private lazy var checkImageView = UIImageView()	// ✓

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setup() // 초기 셋업할 코드들
	}
	
	// Compile time에 error를 발생시키는 코드
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		fatalError("init(coder:) has not been implemented")
	}
}
//MARK: - Action
extension SatisfactionTableViewCell {
	// 외부에서 설정
	func setData(title: String, score: String) {
		self.titleLabel.text = title
		self.scoreLabel.text = score
	}
	
	// 외부에서 설정
	func selectData(_ isSelected: Bool) {
		checkImageView.image = isSelected ? R.Icon.checkOrange24 : R.Icon.checkInActive
	}
}
//MARK: - Style & Layouts
private extension SatisfactionTableViewCell {
	// 초기 셋업할 코드들
	private func setup() {
		setAttribute()
		setLayout()
	}
	
	private func setAttribute() {
		starImageView = starImageView.then {
			$0.image = R.Icon.iconStarOrange48
			$0.contentMode = .scaleAspectFill
		}
		
		scoreLabel = scoreLabel.then {
			$0.font = R.Font.prtendard(family: .medium, size: 14)
			$0.textColor = R.Color.orange500
			$0.textAlignment = .left
			$0.numberOfLines = 1
		}
		
		titleLabel = titleLabel.then {
			$0.font = R.Font.prtendard(family: .medium, size: 16)
			$0.textColor = R.Color.black
			$0.textAlignment = .left
			$0.numberOfLines = 1
		}
		
		checkImageView = checkImageView.then {
			$0.image = R.Icon.checkInActive
			$0.contentMode = .scaleAspectFill
		}
	}
	
	private func setLayout() {
		contentView.addSubviews(starImageView, scoreLabel, titleLabel, checkImageView)
		
		starImageView.snp.makeConstraints {
			$0.leading.equalToSuperview().inset(20)
			$0.centerY.equalToSuperview()
		}
		
		scoreLabel.snp.makeConstraints {
			$0.leading.equalTo(starImageView.snp.trailing).offset(3)
			$0.centerY.equalToSuperview()
		}
		
		titleLabel.snp.makeConstraints {
			$0.leading.equalToSuperview().inset(87)
			$0.centerY.equalToSuperview()
		}
		
		checkImageView.snp.makeConstraints {
			$0.trailing.equalToSuperview().inset(20)
			$0.centerY.equalToSuperview()
		}
	}
}
