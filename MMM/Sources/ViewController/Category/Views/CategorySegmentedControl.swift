//
//  CategorySegmentedControl.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/07.
//

import UIKit
import Then
import SnapKit

final class CategorySegmentedControl: UISegmentedControl {
	// MARK: - UI Components
	private lazy var bgUnderlineView: UIView = {
		let width = self.bounds.size.width
		let height = 2.0
		let xPosition = CGFloat(0)
		let yPosition = self.bounds.size.height - 1.5
		let frame = CGRect(x: xPosition, y: yPosition, width: width, height: height)
		let view = UIView(frame: frame)
		view.backgroundColor = R.Color.gray700
		self.addSubview(view)
		return view
	}()
	
	private lazy var underlineView: UIView = {
		let width = self.bounds.size.width / CGFloat(self.numberOfSegments)
		let height = 2.0
		let xPosition = CGFloat(self.selectedSegmentIndex * Int(width))
		let yPosition = self.bounds.size.height - 1.5
		let frame = CGRect(x: xPosition, y: yPosition, width: width, height: height)
		let view = UIView(frame: frame)
		view.backgroundColor = R.Color.orange500
		self.addSubview(view)
		return view
	}()
	
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
		self.bgUnderlineView.frame.origin.x = 0 // bar의 뒷 배경 위치
		
		let underlineFinalXPosition = (self.bounds.width / CGFloat(self.numberOfSegments)) * CGFloat(self.selectedSegmentIndex)
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
