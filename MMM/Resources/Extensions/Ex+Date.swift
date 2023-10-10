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
    
    func getFormattedTime() -> String {
        let dateformat = DateFormatter()
        dateformat.locale = Locale(identifier: "en_US")
        dateformat.timeZone = TimeZone(abbreviation: "KST")
        dateformat.dateFormat = "a HH:mm"
        return dateformat.string(from: self)
    }
	
	func lastDay() -> String? {
		let year = self.getFormattedDate(format: "yyyy")
		let month = self.getFormattedDate(format: "MM")
		let dateformat = DateFormatter()
		let calendar = Calendar(identifier: .gregorian)
		dateformat.dateFormat = "yyyy-MM-dd"
		let st = dateformat.date(from: "\(year)-\(month)-01")!
		let end = calendar.date(byAdding: .month, value: +1, to: st)!
		let result = calendar.dateComponents([.day], from: st, to: end)

		guard let day = result.day else {
			return nil
		}
		return String(day)
	}
}
