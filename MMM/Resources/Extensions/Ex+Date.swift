//
//  Ex+Date.swift
//  MMM
//
//  Created by geonhyeong on 2023/04/18.
//

import Foundation

extension Date {
	func getFormattedDate(format: String) -> String {
		let dateformat = DateFormatter()
		dateformat.locale = Locale(identifier: "ko_KR")
		dateformat.timeZone = TimeZone(abbreviation: "KST")
		dateformat.dateFormat = format
		return dateformat.string(from: self)
	}
	
	/// format: yyyy-MM-dd
	func getFormattedDefault() -> String {
		let dateformat = DateFormatter()
		dateformat.locale = Locale(identifier: "ko_KR")
		dateformat.timeZone = TimeZone(abbreviation: "KST")
		dateformat.dateFormat = "yyyy-MM-dd"
		return dateformat.string(from: self)
	}
	
	/// format: yyMMdd
	func getFormattedYMD() -> String {
		let dateformat = DateFormatter()
		dateformat.locale = Locale(identifier: "ko_KR")
		dateformat.timeZone = TimeZone(abbreviation: "KST")
		dateformat.dateFormat = "yyyyMMdd"
		return dateformat.string(from: self)
	}
	
	/// format: yyMM
	func getFormattedYM() -> String {
		let dateformat = DateFormatter()
		dateformat.locale = Locale(identifier: "ko_KR")
		dateformat.timeZone = TimeZone(abbreviation: "KST")
		dateformat.dateFormat = "yyyyMM"
		return dateformat.string(from: self)
	}
}
