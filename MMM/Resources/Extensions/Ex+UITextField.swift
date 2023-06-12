//
//  Ex+UITextField.swift
//  MMM
//
//  Created by geonhyeong on 2023/05/23.
//

import UIKit

extension UITextField {	
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
		if tag == 0 {
			self.text = "원"
			self.textColor = R.Color.white
		} else {
			self.text = ""
		}
		sendActions(for: .editingChanged)
	}
}
// MARK: - UITextField Delegate
extension UITextField: UITextFieldDelegate {

	public func textFieldDidChangeSelection(_ textField: UITextField) {
		guard let text = textField.text, let range = textField.selectedTextRange else {
			return
		}

		var start = textField.offset(from: textField.beginningOfDocument, to: range.start)
		var end = textField.offset(from: range.start, to: range.end)
		let len = text.count
		var unit = 0
		
		switch textField.tag {
		case 1: // Detail 수정
			unit = 2 // " 원"의 길이
		case 2: // Home 설정
			unit = 3 // " 만원"의 길이
		default: // Add 추가
			unit = 2 // " 원"의 길이
		}

		if start > len - unit { // 범위 시작이 단위 넘어가지 않도록
			start = text == "원" ? 0 : abs(len - unit)
			end = 0
		} else if start == len - unit { // 범위 시작이 범위의 끝일때
			end = 0 // 드래그 막기
		} else if start + end > len - unit { // 범위 끝이 단위를 넘어가지 않도록
			end = len - unit - start
		}
		
		// cursor 위치 변경
		if let newStartPosition = self.position(from: self.beginningOfDocument, offset: start), let newEndPosition = self.position(from: newStartPosition, offset: end) {
			let newSelectedRange = textField.textRange(from: newStartPosition, to: newEndPosition)
			self.selectedTextRange = newSelectedRange
		}
	}
	
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
			self.text = tag == 0 ? "원" : ""
			self.textColor = tag == 0 ? R.Color.white : R.Color.gray900 // 빈배열로 만든후
			sendActions(for: .editingChanged)
			return false
		}
		
		// 단위에 따른 unuit, 색상 변경
		var limit = Int.max
		var unit = ""
		switch self.tag {
		case 1: // Detail 수정
			unit = " 원"
			limit = 100_000_000
		case 2: // Home 설정
			unit = " 만원"
			limit = 10_000
		default: // Add 추가
			unit = " 원"
			limit = 100_000_000
		}

		// 단위에 따른 color 변경
		self.textColor = price > limit ? R.Color.red500 : self.tag == 0 ? R.Color.white : R.Color.gray900
		
		// 범위가 넘어갈 경우
		if price > limit {
			if let old = Int(oldString.filter{ $0.isNumber }), old > limit {
				
				// cursor 위치 변경
				if let newPosition = self.position(from: self.endOfDocument, offset: -unit.count) {
					let newSelectedRange = textField.textRange(from: newPosition, to: newPosition)
					self.selectedTextRange = newSelectedRange
				}
				return false
			}
		}
		
		// 단위에 따른 unuit 변경
		self.text = result + unit
		
		// 콤마(,) 추가/삭제로 인한 cursor 위치 변경
		let diffComma = abs(result.filter{$0 == ","}.count - newString.filter{$0 == ","}.count) == 1
		var offset = range.location
		offset += string.isEmpty ? (diffComma ? -1 : 0) : 1 + (diffComma ? 1 : 0)
		offset = min(offset, result.count) // 커서가 단위에 있을때

		// cursor 위치 변경
		if let newPosition = self.position(from: self.beginningOfDocument, offset: offset) {
			let newSelectedRange = textField.textRange(from: newPosition, to: newPosition)
			self.selectedTextRange = newSelectedRange
		}
		
		sendActions(for: .editingChanged)

		return false
	}
}
