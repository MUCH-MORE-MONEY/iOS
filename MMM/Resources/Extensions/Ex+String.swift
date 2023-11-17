//
//  Ex+String.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/08/29.
//

import Foundation

extension String {
    //요청 후 json 형태에 escape characters (백슬래쉬)가 들어있으므로 해당 부분을 제거하는 기능 extension String에 추가
    var removedEscapeCharacters: String {
        /// remove: \"
        let removedEscapeWithQuotationMark = self.replacingOccurrences(of: "\\\"", with: "")
        /// remove: \
        let removedEscape = removedEscapeWithQuotationMark.replacingOccurrences(of: "\\", with: "")
        return removedEscape
    }
	
	// "yyyyMMdd"
	func toDate() -> Date? {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyyMMdd"
		dateFormatter.timeZone = TimeZone(identifier: "UTC")
		if let date = dateFormatter.date(from: self) {
			return date
		} else {
			return nil
		}
	}
    
    func toTime() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // 24시간 형식을 피하기 위해 로케일 설정
        if let date = dateFormatter.date(from: self) {
            return date
        } else {
            return nil
        }
    }
}
