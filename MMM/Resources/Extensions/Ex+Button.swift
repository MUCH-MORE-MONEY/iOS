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
    
    func setButtonLayer() {
        self.layer.cornerRadius = 4
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.25
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 8
    }
    
    
    func alignTextBelow(spacing: CGFloat = 4.0) {
            guard let image = self.imageView?.image else {
                return
            }

            guard let titleLabel = self.titleLabel else {
                return
            }

            guard let titleText = titleLabel.text else {
                return
            }

            let titleSize = titleText.size(withAttributes: [
                NSAttributedString.Key.font: titleLabel.font as Any
            ])

            titleEdgeInsets = UIEdgeInsets(top: spacing, left: -image.size.width, bottom: -image.size.height, right: 0)
            imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + spacing), left: 0, bottom: 0, right: -titleSize.width)
        }
    // MARK: - 원형 버튼 만드는 코드
    func setRoundButton() {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
    }
}
