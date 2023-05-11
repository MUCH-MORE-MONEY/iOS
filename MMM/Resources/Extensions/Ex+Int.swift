//
//  Ex+Int.swift
//  MMM
//
//  Created by geonhyeong on 2023/04/05.
//

import Foundation

extension Int {
	// 100단위마다 ","를 찍어주는 기능
	func withCommas() -> String {
		let numberFormatter = NumberFormatter()
		numberFormatter.numberStyle = .decimal
		return numberFormatter.string(from: NSNumber(value:self))!
	}
	
	// 100단위마다 "+", ","를 찍어주는 기능
	func withCommasAndPlus() -> String {
		let numberFormatter = NumberFormatter()
		numberFormatter.numberStyle = .decimal
		numberFormatter.positivePrefix = "+"
		return numberFormatter.string(from: NSNumber(value:self))!
	}
}
