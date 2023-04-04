//
//  Ex+Button.swift
//  MMM
//
//  Created by geonhyeong on 2023/04/04.
//

import UIKit

extension UIButton {
	//MARK: state 별로 UIButton의 background color 변경
	func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
		UIGraphicsBeginImageContext(CGSize(width: 1.0, height: 1.0))
		guard let context = UIGraphicsGetCurrentContext() else { return }
		self.clipsToBounds = true
		context.setFillColor(color.cgColor)
		context.fill(CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))
		
		let backgroundImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		self.setBackgroundImage(backgroundImage, for: state)
	}
}
