//
//  HomeTableViewCell.swift
//  MMM
//
//  Created by geonhyeong on 2023/04/18.
//

import UIKit

final class HomeTableViewCell: UITableViewCell {
	
	private lazy var image = UIImageView().then {
		$0.layer.cornerRadius = 20
		$0.layer.backgroundColor = R.Color.gray100.cgColor
		$0.contentMode = .scaleAspectFit
	}
	
	// contains2StackView과 memoLabel 들어가는 view
	private lazy var containsStackView = UIStackView().then {
		$0.axis = .vertical
		$0.spacing = 7
		$0.alignment = .leading
		$0.distribution = .fill
	}
	
	// starStackView과 title이 들어가는 view
	private lazy var contains2StackView = UIStackView().then {
		$0.axis = .vertical
		$0.spacing = 4
		$0.alignment = .leading
		$0.distribution = .fill
	}
	
	// +/- imageView와 가격이 들어가는 view
	private lazy var contains3StackView = UIStackView().then {
		$0.axis = .horizontal
		$0.spacing = 4
		$0.alignment = .center
		$0.distribution = .fill
	}
	
	private lazy var starStackView = UIStackView().then {
		$0.axis = .horizontal
		$0.spacing = 3.77
		$0.alignment = .leading
		$0.distribution = .fillEqually
	}
	
	private lazy var titleLabel = UILabel().then {
		$0.font = R.Font.body2
		$0.textColor = R.Color.black
		$0.textAlignment = .left
		$0.numberOfLines = 1
	}
	
	private lazy var memoLabel = UILabel().then {
		$0.font = R.Font.body5
		$0.textColor = R.Color.gray600
		$0.textAlignment = .left
		$0.numberOfLines = 1
	}
	
	private lazy var plusMinusImage = UIImageView().then {
		$0.contentMode = .scaleAspectFit
	}
		
	private lazy var priceLabel = UILabel().then {
		$0.font = R.Font.prtendard(family: .medium, size: 16)
		$0.textColor = R.Color.black
		$0.textAlignment = .left
	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setLayout()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		fatalError("init(coder:) has not been implemented")
	}

	private func setLayout() {
		contentView.addSubviews(image, containsStackView, contains3StackView)
		[contains2StackView, memoLabel].forEach {
			containsStackView.addArrangedSubview($0)
		}

		[starStackView, titleLabel].forEach {
			contains2StackView.addArrangedSubview($0)
		}

		[plusMinusImage, priceLabel].forEach {
			contains3StackView.addArrangedSubview($0)
		}

		image.snp.makeConstraints {
			$0.leading.equalToSuperview().inset(20)
			$0.centerY.equalToSuperview()
			$0.width.height.equalTo(40)
		}

		containsStackView.snp.makeConstraints {
			$0.leading.equalTo(image.snp.trailing).offset(16)
			$0.trailing.equalToSuperview().inset(20)
			$0.centerY.equalToSuperview()
		}

		contains2StackView.snp.makeConstraints {
			$0.trailing.lessThanOrEqualTo(contains3StackView.snp.leading)
		}

		contains3StackView.snp.makeConstraints {
			$0.trailing.equalToSuperview().inset(20)
			$0.centerY.equalTo(titleLabel.snp.centerY)
		}
	}
}

extension HomeTableViewCell {
	func setUp(data: Calendar) {
		image.image = data.image.isEmpty ? data.isEarn ? R.Icon.coinEarn40 : R.Icon.coinPay40 : R.Icon.mypageBg
		
		// star의 갯수
		for _ in 0..<data.star {
			let star = UIImageView(image: R.Icon.iconStarActive)
			starStackView.addArrangedSubview(star)
		}
		
		// 5 - star의 갯수
		for _ in 0..<5-data.star {
			let star = UIImageView(image: R.Icon.iconStarInActive)
			starStackView.addArrangedSubview(star)
		}
		
		titleLabel.text = data.title
		memoLabel.text = data.memo
		plusMinusImage.image = data.isEarn ? R.Icon.plus16 : R.Icon.minus16
		priceLabel.text = data.price.withCommas()
	}
}