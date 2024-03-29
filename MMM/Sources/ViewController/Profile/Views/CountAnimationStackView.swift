//
//  CountAnimationStackView.swift
//  MMM
//
//  Created by geonhyeong on 2023/04/06.
//

import UIKit
import Then
import SnapKit

// 상속하지 않으려면 final 꼭 붙이기
final class CountAnimationStackView: BaseView {
	// MARK: - Properties
	
	// MARK: - UI Components
	private lazy var containerStackView = UIStackView()
	private lazy var firstLabel = UILabel()
	private lazy var signLabel = UILabel()
	private lazy var middleLabel = CountScrollLabel()
	private lazy var unitLabel = UILabel()
	private lazy var secondLabel = UILabel()
}
//MARK: - Action
extension CountAnimationStackView {
	// 외부에서 설정
	public func setData(first: String, second: String, money: Int, unitText: String, duration: TimeInterval) {
		self.firstLabel.text = first
		self.secondLabel.text = second
		self.unitLabel.text = unitText
		
		let width = middleLabel.config(num: "\(abs(money))", duration: duration, isMoney: unitText == "원")
		signLabel.text = money >= 0 ? "" : "-"
		middleLabel.animate(ascending: false)
		
		middleLabel.snp.makeConstraints {
			$0.width.equalTo(width)
		}
	}
}
//MARK: - Attribute & Hierarchy & Layouts
extension CountAnimationStackView {
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()
		
		containerStackView = containerStackView.then {
			$0.axis = .horizontal
			$0.spacing = 0
			$0.alignment = .leading
		}
		
		firstLabel = firstLabel.then {
			$0.font = R.Font.prtendard(family: .medium, size: 16)
			$0.textColor = R.Color.gray800
			$0.textAlignment = .left
		}
		
		signLabel = signLabel.then {
			$0.font = R.Font.prtendard(family: .medium, size: 16)
			$0.textColor = R.Color.orange500
			$0.textAlignment = .right
		}
		
		unitLabel = unitLabel.then {
			$0.font = R.Font.prtendard(family: .medium, size: 16)
			$0.textColor = R.Color.orange500
			$0.textAlignment = .left
		}
		
		secondLabel = secondLabel.then {
			$0.font = R.Font.prtendard(family: .medium, size: 16)
			$0.textColor = R.Color.gray800
			$0.textAlignment = .left
		}
	}
	
	override func setHierarchy() {
		super.setHierarchy()
		
		addSubview(containerStackView)
		containerStackView.addArrangedSubviews(firstLabel, signLabel, middleLabel, unitLabel, secondLabel)
	}
	
	override func setLayout() {
		super.setLayout()
		
		containerStackView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
	}
}
