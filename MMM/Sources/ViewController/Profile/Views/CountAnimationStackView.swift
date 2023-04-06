//
//  CountAnimationStackView.swift
//  MMM
//
//  Created by geonhyeong on 2023/04/06.
//

import UIKit

class CountAnimationStackView: UIView {
	private lazy var containerStackView = UIStackView().then {
		$0.axis = .horizontal
		$0.spacing = 0
		$0.alignment = .leading
	}
	
	private lazy var firstLabel = UILabel().then {
		$0.font = R.Font.prtendard(family: .medium, size: 16)
		$0.textColor = R.Color.gray800
		$0.textAlignment = .left
	}
	
	private lazy var middleLabel = CountScrollLabel()
		
	private lazy var unitLabel = UILabel().then {
		$0.font = R.Font.prtendard(family: .medium, size: 16)
		$0.textColor = R.Color.orange500
		$0.textAlignment = .left
	}
	
	private lazy var secondLabel = UILabel().then {
		$0.font = R.Font.prtendard(family: .medium, size: 16)
		$0.textColor = R.Color.gray800
		$0.textAlignment = .left
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setLayout()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

//MARK: - setUp & Layouts
extension CountAnimationStackView {
	public func setUp(first: String, second: String, money: Int, unitText: String, duration: TimeInterval) {
		self.firstLabel.text = first
		self.secondLabel.text = second
		self.unitLabel.text = unitText
		
		let width = middleLabel.config(num: "\(money)", duration: duration, isMoney: unitText == "원")
		middleLabel.animate(ascending: false)
		
		middleLabel.snp.makeConstraints {
			$0.width.equalTo(width)
		}
	}
	
	public func setLayout() {
		addSubview(containerStackView)
		[firstLabel, middleLabel, unitLabel, secondLabel].forEach {
			containerStackView.addArrangedSubview($0)
		}
		
		containerStackView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
	}
}
