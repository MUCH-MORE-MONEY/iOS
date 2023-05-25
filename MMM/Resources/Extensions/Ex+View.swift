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
}
