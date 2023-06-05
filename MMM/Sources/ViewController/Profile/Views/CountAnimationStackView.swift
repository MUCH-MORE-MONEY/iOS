//
//  CountAnimationStackView.swift
//  MMM
//
//  Created by geonhyeong on 2023/04/06.
//

import UIKit

class CountAnimationStackView: UIView {
	// MARK: - Properties
	// MARK: - UI Components
	private lazy var containerStackView = UIStackView()
	private lazy var firstLabel = UILabel()
	private lazy var middleLabel = CountScrollLabel()
	private lazy var unitLabel = UILabel()
	private lazy var secondLabel = UILabel()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup() // 초기 셋업할 코드들
	}
	
	// Compile time에 error를 발생시키는 코드
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
//MARK: - Action
extension CountAnimationStackView {
	// 외부에서 설정
	public func setData(first: String, second: String, money: Int, unitText: String, duration: TimeInterval) {
		self.firstLabel.text = first
		self.secondLabel.text = second
		self.unitLabel.text = unitText
		
		let width = middleLabel.config(num: "\(money)", duration: duration, isMoney: unitText == "원")
		middleLabel.animate(ascending: false)
		
		middleLabel.snp.makeConstraints {
			$0.width.equalTo(width)
		}
	}
}
//MARK: - Style & Layouts
private extension CountAnimationStackView {
	// 초기 셋업할 코드들
	private func setup() {
		setAttribute()
		setLayout()
	}
	
	private func setAttribute() {
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
	
	private func setLayout() {
		addSubview(containerStackView)
		containerStackView.addArrangedSubviews(firstLabel, middleLabel, unitLabel, secondLabel)
		
		containerStackView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
	}
}
