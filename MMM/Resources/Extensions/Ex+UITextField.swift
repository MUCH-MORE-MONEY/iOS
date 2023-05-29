//
//  Ex+UITextField.swift
//  MMM
//
//  Created by geonhyeong on 2023/05/23.
//

import UIKit

extension UITextField {
	/// 밑줄
	func setUnderLine(color: UIColor) {
		let border = CALayer()
		border.frame = CGRect(x: 0, y: self.frame.size.height + 4, width: self.frame.width, height: 2)
		border.borderColor = color.cgColor
		border.borderWidth = 1
		self.borderStyle = .none
		self.layer.addSublayer(border)
	}
	
	/// Clear button
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
	
	/// Only Number & Delegate,
	/// unit: 단위(default: "원", etc: " 원", "만원"...)
	func setNumberMode(unit: String = "원") {
		delegate = self
		
		switch unit {
		case " 원": self.tag = 1
		case "만원": self.tag = 2
		default: self.tag = 0
		}
	}
	
	@objc private func displayClearButtonIfNeeded() {
		self.rightView?.isHidden = (self.text?.isEmpty) ?? true
	}
	
	@objc func clear(sender: AnyObject) {
		self.text = ""
		sendActions(for: .editingChanged)
	}
}
// MARK: - UITextField Delegate
extension UITextField: UITextFieldDelegate {
	// text가 변경할지에 대한 delegate요청 메소드
	public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		// oldString: 기존에 입력되었던 text
		// newRange: 입력으로 예상되는 text의 range값 추측 > range값을 알면 기존 문자열에 새로운 문자를 위치에 알맞게 추가 가능
		/// Range(range, in: text): 갱신된 range값과 기존 string을 가지고 객체 변환: NSRange > Range
		guard let oldString = textField.text, let newRange = Range(range, in: oldString) else { return true }
		
		// range값과 inputString을 가지고 replacingCharacters(in:with:)을 이용하여 string 업데이트
		let inputString = string.trimmingCharacters(in: .whitespacesAndNewlines)
		let newString = oldString.replacingCharacters(in: newRange, with: inputString)
			.trimmingCharacters(in: .whitespacesAndNewlines)
		let newStringOnlyNumber = newString.filter { $0.isNumber }
				
		let numberFormatter = NumberFormatter()
		numberFormatter.numberStyle = .decimal // 콤마 생성
		
		guard let price = Int(newStringOnlyNumber), let result = numberFormatter.string(from: NSNumber(value: price)) else {
			self.text = ""
			sendActions(for: .editingChanged)
			return true
		}
		
		// 단위에 따른 unuit, 색상 변경
		var limit = Int.max
		var unit = ""
		switch self.tag {
		case 1:
			unit = " 원"
			limit = 100_000_000
		case 2:
			unit = "만원"
			limit = 10_000
		default:
			unit = "원"
		}

		// 단위에 따른 color 변경
		self.textColor = price > limit ? R.Color.red500 : R.Color.gray900
		if price > limit {
			DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
				self.text = limit.withCommas() + unit
				self.textColor = R.Color.gray900
				// cursor 위치 변경
				if let newPosition = self.position(from: self.endOfDocument, offset: -unit.count) {
					let newSelectedRange = textField.textRange(from: newPosition, to: newPosition)
					self.selectedTextRange = newSelectedRange
				}
				self.sendActions(for: .editingChanged)
			}
			if let old = Int(oldString.filter{ $0.isNumber }), old > limit {
				return false
			}
		}
		
		// 단위에 따른 unuit 변경
		self.text = result + unit
		
		// 콤마(,) 추가/삭제로 인한 cursor 위치 변경
		let diffComma = abs(result.filter{$0 == ","}.count - newString.filter{$0 == ","}.count) == 1
		var offset = range.location
		offset += string.isEmpty ? (diffComma ? -1 : 0) : 1 + (diffComma ? 1 : 0)
		
		// cursor 위치 변경
		if let newPosition = self.position(from: self.beginningOfDocument, offset: offset) {
			let newSelectedRange = textField.textRange(from: newPosition, to: newPosition)
			self.selectedTextRange = newSelectedRange
		}
		
		sendActions(for: .editingChanged)

		return false
	}
}
