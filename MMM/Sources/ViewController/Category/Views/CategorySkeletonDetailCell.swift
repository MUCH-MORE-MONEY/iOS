//
//  CategorySkeletonDetailCell.swift
//  MMM
//
//  Created by geonhyeong on 11/30/23.
//

import UIKit
import Then
import SnapKit

// 상속하지 않으려면 final 꼭 붙이기
final class CategorySkeletonDetailCell: BaseTableViewCell {
	// MARK: - Constants
	private enum UI { }
	// MARK: - Properties
	// MARK: - UI Components
	private lazy var thumbnailImageView = UIImageView()
	private lazy var thumbnailLayer = CAGradientLayer()
	
	private lazy var starView = UIView()
	private lazy var starLayer = CAGradientLayer()
	
	private lazy var titleView = UIView()
	private lazy var titleLayer = CAGradientLayer()
	
	private lazy var descriptionView = UIView()
	private lazy var descriptionLayer = CAGradientLayer()

	private lazy var separator = UIView()

	override func layoutSubviews() {
		super.layoutSubviews()
		
		thumbnailLayer.frame = thumbnailImageView.bounds
		thumbnailLayer.cornerRadius = thumbnailImageView.bounds.height / 2
		
		starLayer.frame = starView.bounds
		starLayer.cornerRadius = 4
		
		titleLayer.frame = titleView.bounds
		titleLayer.cornerRadius = 4
		
		descriptionLayer.frame = descriptionView.bounds
		descriptionLayer.cornerRadius = 4
	}
	
	// 재활용 셀 중접오류 해결
	override func prepareForReuse() {
		self.separator.isHidden = true
	}
}
//MARK: - Action
extension CategorySkeletonDetailCell {
	// 외부에서 설정
	func setData(last: Bool) {
		DispatchQueue.main.async {
			self.separator.isHidden = last
		}
		
		contentView.snp.updateConstraints {
			$0.height.equalTo(88)
			$0.width.equalToSuperview()
		}
	}
}
//MARK: - Attribute & Hierarchy & Layouts
extension CategorySkeletonDetailCell: SkeletonLoadable {
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()
		
		let thumbnailGroup = makeAnimationGroup()
		thumbnailGroup.beginTime = 0.0
		thumbnailLayer = thumbnailLayer.then {
			$0.startPoint = CGPoint(x: 0, y: 0.5)
			$0.endPoint = CGPoint(x: 1, y: 0.5)
			$0.add(thumbnailGroup, forKey: "backgroundColor")
		}
		
		thumbnailImageView = thumbnailImageView.then {
			$0.frame = .init(origin: .zero, size: .init(width: 40, height: 40))
			$0.layer.cornerRadius = 20
			$0.layer.backgroundColor = R.Color.gray100.cgColor
			$0.layer.masksToBounds = true	// 모양대로 자르기
			$0.contentMode = .scaleAspectFill
			$0.layer.addSublayer(thumbnailLayer)
		}

		let secondGroup = makeAnimationGroup(previousGroup: thumbnailGroup)
		starLayer = starLayer.then {
			$0.startPoint = CGPoint(x: 0, y: 0.5)
			$0.endPoint = CGPoint(x: 1, y: 0.5)
			$0.add(secondGroup, forKey: "backgroundColor")
		}
		
		starView = starView.then {
			$0.frame = .init(origin: .zero, size: .init(width: 60, height: 12))
			$0.layer.addSublayer(starLayer)
		}
		
		titleLayer = titleLayer.then {
			$0.startPoint = CGPoint(x: 0, y: 0.5)
			$0.endPoint = CGPoint(x: 1, y: 0.5)
			$0.add(secondGroup, forKey: "backgroundColor")
		}
		
		titleView = titleView.then {
			$0.frame = .init(origin: .zero, size: .init(width: 49, height: 20))
			$0.layer.addSublayer(titleLayer)
		}
		
		descriptionLayer = descriptionLayer.then {
			$0.startPoint = CGPoint(x: 0, y: 0.5)
			$0.endPoint = CGPoint(x: 1, y: 0.5)
			$0.add(secondGroup, forKey: "backgroundColor")
		}
		
		descriptionView = descriptionView.then {
			let bounds = UIScreen.width - 76 - 20 // 왼쪽, 오른쪽 여백
			$0.frame = .init(origin: .zero, size: .init(width: bounds, height: 20))
			$0.layer.addSublayer(descriptionLayer)
		}

		separator = separator.then {
			$0.isHidden = true
			$0.backgroundColor = R.Color.gray200
		}
	}
	
	override func setHierarchy() {
		super.setHierarchy()
		
		contentView.addSubviews(thumbnailImageView, starView, titleView, descriptionView, separator)
	}
	
	override func setLayout() {
		super.setLayout()

		thumbnailImageView.snp.makeConstraints {
			$0.leading.equalToSuperview().inset(20)
			$0.centerY.equalToSuperview()
			$0.width.height.equalTo(40)
		}
		
		starView.snp.makeConstraints {
			$0.leading.equalTo(thumbnailImageView.snp.trailing).offset(16)
			$0.top.equalToSuperview().inset(15)
		}
		
		titleView.snp.makeConstraints {
			$0.leading.equalTo(thumbnailImageView.snp.trailing).offset(16)
			$0.top.equalToSuperview().inset(31)
		}
		
		descriptionView.snp.makeConstraints {
			$0.leading.equalTo(thumbnailImageView.snp.trailing).offset(16)
			$0.top.equalToSuperview().inset(58)
		}
		
		separator.snp.makeConstraints {
			$0.leading.trailing.equalToSuperview().inset(20)
			$0.bottom.equalToSuperview()
			$0.height.equalTo(1)
		}
	}
}
