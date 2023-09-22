//
//  CategorySegmentedControl.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/07.
//

import UIKit
import Then
import SnapKit

// 상속하지 않으려면 final 꼭 붙이기
final class CategorySegmentedControl: UISegmentedControl {
	// MARK: - Constants
	private enum UI {
		static let sideMargin: CGFloat = 24
		static let underLineHeight: CGFloat = 24
	}
	
	// MARK: - UI Components
	private lazy var bgUnderlineView = UIView().then {
		let width = (self.bounds.size.width - UI.sideMargin * 2)
		let height = UI.underLineHeight
		let xPosition = CGFloat(UI.sideMargin)
		let yPosition = self.bounds.size.height - 1.5
		let frame = CGRect(x: xPosition, y: yPosition, width: width, height: height)
		$0.frame = frame
		$0.backgroundColor = R.Color.gray500
		self.addSubview($0)
	}

	private lazy var underlineView = UIView().then {
		let width = (self.bounds.size.width - UI.sideMargin * 2) / CGFloat(self.numberOfSegments)
		let height = UI.underLineHeight
		let xPosition = CGFloat(self.selectedSegmentIndex * Int(width))
		let yPosition = self.bounds.size.height - 1.5
		let frame = CGRect(x: xPosition, y: yPosition, width: width, height: height)
		$0.frame = frame
		$0.backgroundColor = R.Color.orange500
		self.addSubview($0)
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.removeBackgroundAndDivider()
	}
	
	override init(items: [Any]?) {
		super.init(items: items)
		self.removeBackgroundAndDivider()
	}
	
	// Compile time에 error를 발생시키는 코드
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// layoutSubviews를 통해 underlineView 추가
	override func layoutSubviews() {
		super.layoutSubviews()
		self.layer.cornerRadius = 0 // 기본적으로 지정되어 있는 radius 제거
		self.bgUnderlineView.frame.origin.x = UI.sideMargin // bar의 뒷 배경 위치
		
		let underlineFinalXPosition = UI.sideMargin + ((self.bounds.width - UI.sideMargin * 2) / CGFloat(self.numberOfSegments)) * CGFloat(self.selectedSegmentIndex)
		UIView.animate(withDuration: 0.1, animations: {
			self.underlineView.frame.origin.x = underlineFinalXPosition
			self.underlineView.backgroundColor = self.selectedSegmentIndex == 0 ? R.Color.orange500 : R.Color.blue500
		})
	}
}
//MARK: - Action
extension CategorySegmentedControl {
	// 회색 배경과 divider를 지우는 코드
	private func removeBackgroundAndDivider() {
		let image = UIImage()
		self.setBackgroundImage(image, for: .normal, barMetrics: .default)
		self.setBackgroundImage(image, for: .selected, barMetrics: .default)
		self.setBackgroundImage(image, for: .highlighted, barMetrics: .default)
		self.setDividerImage(image, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
	}
}
