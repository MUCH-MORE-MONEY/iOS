//
//  HomeTableViewCell.swift
//  MMM
//
//  Created by geonhyeong on 2023/04/18.
//

import UIKit
import Then
import SnapKit

final class HomeTableViewCell: UITableViewCell {
	// MARK: - Properties
	// MARK: - UI Components
	private lazy var startList = [UIImageView]()
	private lazy var thumbnailImageView = UIImageView()
	// contains2StackView과 memoLabel 들어가는 view
	private lazy var containsStackView = UIStackView()
	// starStackView과 title이 들어가는 view
	private lazy var contains2StackView = UIStackView()
	// +/- imageView와 가격이 들어가는 view
	private lazy var contains3StackView = UIStackView()
	private lazy var starStackView = UIStackView()
	private lazy var titleLabel = UILabel()
	private lazy var memoLabel = UILabel()
	private lazy var plusMinusImage = UIImageView()
	private lazy var priceLabel = UILabel()
	private lazy var separator = UIView()

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
	
	// 재활용 셀 중접오류 해결
	override func prepareForReuse() {
		startList.forEach { iv in
			iv.image = nil
			iv.image = R.Icon.iconStarDisabled8
		}
		self.separator.isHidden = true
	}
}
//MARK: - Action
extension HomeTableViewCell {
	// 외부에서 설정
	func setData(data: EconomicActivity, last: Bool) {
		// 이미지 비동기 처리
		DispatchQueue.main.async {
			self.thumbnailImageView.setImage(urlStr: data.imageUrl, defaultImage: data.type == "01" ? R.Icon.coinPay40 : R.Icon.coinEarn40)
			
			self.separator.isHidden = last
		}
		
		// star의 갯수
		for i in 0..<data.star {
			startList[i].image = R.Icon.iconStarBlack8
		}

		titleLabel.text = data.title
		memoLabel.text = data.memo
		plusMinusImage.image = data.type == "01" ? R.Icon.minus16 : R.Icon.plus16
		priceLabel.text = data.amount.withCommas()
	}
}
//MARK: - Attribute & Hierarchy & Layouts
private extension HomeTableViewCell {
	// 초기 셋업할 코드들
	private func setup() {
		setAttribute()
		setLayout()
	}
	
	private func setAttribute() {
		startList = [UIImageView(image: R.Icon.iconStarDisabled8),
					 UIImageView(image: R.Icon.iconStarDisabled8),
					 UIImageView(image: R.Icon.iconStarDisabled8),
					 UIImageView(image: R.Icon.iconStarDisabled8),
					 UIImageView(image: R.Icon.iconStarDisabled8)]
		
		thumbnailImageView = thumbnailImageView.then {
			$0.layer.cornerRadius = 20
			$0.layer.backgroundColor = R.Color.gray100.cgColor
			$0.layer.masksToBounds = true	// 모양대로 자르기
			$0.contentMode = .scaleAspectFill
		}
		
		containsStackView = containsStackView.then {
			$0.axis = .vertical
			$0.spacing = 7
			$0.alignment = .leading
			$0.distribution = .fill
		}
		
		contains2StackView = contains2StackView.then {
			$0.axis = .vertical
			$0.spacing = 4
			$0.alignment = .leading
			$0.distribution = .fill
		}
		
		contains3StackView = contains3StackView.then {
			$0.axis = .horizontal
			$0.spacing = 4
			$0.alignment = .center
			$0.distribution = .fill
		}
		
		starStackView = starStackView.then {
			$0.axis = .horizontal
			$0.spacing = 3.77
			$0.alignment = .leading
			$0.distribution = .fillEqually
		}
		
		titleLabel = titleLabel.then {
			$0.font = R.Font.body2
			$0.textColor = R.Color.black
			$0.textAlignment = .left
			$0.numberOfLines = 1
		}
		
		memoLabel = memoLabel.then {
			$0.font = R.Font.body5
			$0.textColor = R.Color.gray600
			$0.textAlignment = .left
			$0.numberOfLines = 1
		}
		
		plusMinusImage = plusMinusImage.then {
			$0.contentMode = .scaleAspectFit
		}
		
		priceLabel = priceLabel.then {
			$0.font = R.Font.prtendard(family: .medium, size: 16)
			$0.textColor = R.Color.black
			$0.textAlignment = .left
		}
		
		separator = separator.then {
			$0.isHidden = true
			$0.backgroundColor = R.Color.gray200
		}
	}
	
	private func setLayout() {
		contentView.addSubviews(thumbnailImageView, containsStackView, contains3StackView, separator)
		startList.forEach { imageView in
			starStackView.addArrangedSubview(imageView)
		}
		
		[contains2StackView, memoLabel].forEach {
			containsStackView.addArrangedSubview($0)
		}

		[starStackView, titleLabel].forEach {
			contains2StackView.addArrangedSubview($0)
		}

		[plusMinusImage, priceLabel].forEach {
			contains3StackView.addArrangedSubview($0)
		}

		thumbnailImageView.snp.makeConstraints {
			$0.leading.equalToSuperview().inset(20)
			$0.centerY.equalToSuperview()
			$0.width.height.equalTo(40)
		}

		containsStackView.snp.makeConstraints {
			$0.leading.equalTo(thumbnailImageView.snp.trailing).offset(16)
			$0.trailing.equalToSuperview().inset(20)
			$0.centerY.equalToSuperview()
		}

		contains3StackView.snp.makeConstraints {
			$0.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(11)
			$0.trailing.equalToSuperview().inset(20)
			$0.centerY.equalTo(titleLabel.snp.centerY)
		}
		
		separator.snp.makeConstraints {
			$0.leading.trailing.equalToSuperview().inset(20)
			$0.bottom.equalToSuperview()
			$0.height.equalTo(1)
		}
	}
}
