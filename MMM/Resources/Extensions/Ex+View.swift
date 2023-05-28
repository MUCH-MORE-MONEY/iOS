//
//  Ex+View.swift
//  MMM
//
//  Created by geonhyeong on 2023/03/27.
//  Copyright © 2023 Lab.M. All rights reserved.
//

import UIKit
import Combine

extension UIView {
    func throttleTapGesturePublisher() -> Publishers.Throttle<UITapGestureRecognizer.GesturePublisher<UITapGestureRecognizer>, RunLoop> {
        return UITapGestureRecognizer.GesturePublisher(recognizer: .init(), view: self)
            .throttle(for: .seconds(1),
                      scheduler: RunLoop.main,
                      latest: false)
    }
    
	func addSubviews(_ views: UIView...) {
		views.forEach { addSubview($0) }
	}
	
	// CALayer를 이용하여 UIView의 하단에 줄을 긋는 함수
	func addAboveTheBottomBorderWithColor(color: UIColor) {
		let border = CALayer()
		border.backgroundColor = color.cgColor
		border.frame = CGRect(x: 0, y: self.frame.size.height - 1, width: self.frame.size.width, height: 1)
		self.layer.addSublayer(border)
	}
	
	// 특정 텍스트 필드의 x축 값을 변경하는 애니메이션 함수
	func shake() {
		let animation = CAKeyframeAnimation(keyPath: "position.x")
		animation.values = [0, 10, -10, 10, 0] // x축 상수 값이 원점, 왼쪽, 오른쪽, 왼쪽, 원점으로 이어짐
		animation.keyTimes = [0, 0.08, 0.24, 0.415, 0.5]
		animation.duration = 0.5
		animation.fillMode = .forwards
		animation.isRemovedOnCompletion = false
		animation.isAdditive = true // 현재 주어진 텍스트 필드의 위치에 해당 x값이 추가되는 구조
		layer.add(animation, forKey: nil)
	}
}
