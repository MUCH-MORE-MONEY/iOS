//
//  Ex+UITextField.swift
//  MMM
//
//  Created by geonhyeong on 2023/05/23.
//

import UIKit

public extension UITextField {
	// 밑줄
	func setUnderLine(color: UIColor) {
		let border = CALayer()
		border.frame = CGRect(x: 0, y: self.frame.size.height + 4, width: self.frame.width, height: 2)
		border.borderColor = color.cgColor
		border.borderWidth = 1
		self.borderStyle = .none
		self.layer.addSublayer(border)
	}
	
	// Clear button
	func setClearButton(with image: UIImage?, mode: UITextField.ViewMode) {
		let clearButton = UIButton(type: .custom)
		clearButton.setImage(image, for: .normal)
		clearButton.frame = CGRect(x: 0, y: 0, width: 18, height: 18)
		clearButton.contentMode = .scaleAspectFit
		clearButton.addTarget(self, action: #selector(UITextField.clear), for: .touchUpInside)

		self.addTarget(self, action: #selector(UITextField.displayClearButtonIfNeeded), for: .editingDidBegin)
		self.addTarget(self, action: #selector(UITextField.displayClearButtonIfNeeded), for: .editingChanged)
		self.rightView = clearButton
		self.rightViewMode = mode
	}

	@objc private func displayClearButtonIfNeeded() {
		self.rightView?.isHidden = (self.text?.isEmpty) ?? true
	}
	
	@objc func clear(sender: AnyObject) {
		self.text = ""
		sendActions(for: .editingChanged)
	}
}
