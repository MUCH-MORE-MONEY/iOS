//
//  CalendarCell.swift
//  MMM
//
//  Created by geonhyeong on 2023/05/08.
//

import FSCalendar
import UIKit
import Then
import SnapKit

final class CalendarCell: FSCalendarCell {
	// MARK: - Properties
	// MARK: - UI
	lazy var selectionLayer = CAShapeLayer()
	lazy var todayLayer = CAShapeLayer()
	lazy var borderLayer = CAShapeLayer()

	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	// Compile time에 error를 발생시키는 코드
	@available(*, unavailable)
	required init?(coder: NSCoder!) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// 재활용 셀 중접오류 해결
	override func prepareForReuse() {
		super.prepareForReuse()
		self.selectionLayer.fillColor = nil
		self.borderLayer.isHidden = true
	}
		
	override func layoutSubviews() {
		super.layoutSubviews()
		self.backgroundView?.frame = self.bounds.insetBy(dx: 1, dy: 1)
		self.selectionLayer.frame = .init(origin: .zero, size: .init(width: 24, height: 24))
		self.todayLayer.frame = .init(origin: .zero, size: .init(width: 24, height: 24))
		self.borderLayer.frame = .init(origin: .zero, size: .init(width: 24, height: 24))

		let diameter: CGFloat = min(self.selectionLayer.frame.height, self.selectionLayer.frame.width)
		let (x, y) = (self.contentView.frame.width / 2 - diameter / 2, self.contentView.frame.height / 2 - diameter / 2)
		
		self.selectionLayer.path = UIBezierPath(ovalIn: CGRect(x: x, y: y, width: diameter, height: diameter)).cgPath // 기본 선택에 대한 동그라미 path
		self.todayLayer.path = UIBezierPath(roundedRect: CGRect(x: x, y: y, width: diameter, height: diameter), byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 12, height: 12)).cgPath // 오늘 날짜의 border
		self.borderLayer.path = UIBezierPath(roundedRect: CGRect(x: x, y: y, width: diameter, height: diameter), byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 12, height: 12)).cgPath // 오늘 날짜의 border
	}
	
	override func configureAppearance() {
		super.configureAppearance()
		
		if self.dateIsToday {
			// 오늘날짜에 대한 font
			self.titleLabel.font = R.Font.body4
			self.todayLayer.isHidden = false
		}
		
		// 선택한 date의 border 보임/이전 Border 숨김
		self.borderLayer.isHidden = !self.isSelected
	}
}

extension CalendarCell {
	// 외부에서 입력
	func setUp(color: UIColor) {
		self.selectionLayer.fillColor = color.cgColor
	}
}

//MARK: - Style & Layouts
private extension CalendarCell {
	// 초기 셋업할 코드들
	func setup() {
		setAttribute()
		setLayout()
	}
	
	// 속성
	func setAttribute() {
		self.backgroundView?.frame = self.bounds.insetBy(dx: 1, dy: 1)

		shapeLayer = shapeLayer.then {
			$0.isHidden = true // 기존에 있던 select default 색상
		}
		
		selectionLayer = CAShapeLayer().then {
			$0.fillColor = UIColor.clear.cgColor
		}
		
		borderLayer = CAShapeLayer().then {
			$0.fillColor = UIColor.clear.cgColor
			$0.strokeColor = R.Color.white.cgColor
			$0.lineWidth = 2
			$0.isHidden = true
		}
		
		todayLayer = CAShapeLayer().then {
			$0.fillColor = UIColor.clear.cgColor
			$0.strokeColor = R.Color.gray900.cgColor
			$0.lineWidth = 3
			$0.isHidden = true
		}
	}
	
	// 레이아웃
	func setLayout() {
		self.contentView.layer.insertSublayer(selectionLayer, below: self.titleLabel!.layer)
		self.contentView.layer.insertSublayer(todayLayer, below: self.titleLabel!.layer)
		self.contentView.layer.insertSublayer(borderLayer, below: self.titleLabel!.layer)
	}
}
