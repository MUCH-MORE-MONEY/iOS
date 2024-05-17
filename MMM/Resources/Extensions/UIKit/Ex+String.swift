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
        dateFormatter.timeZone = TimeZone(identifier: "KST")
        if let date = dateFormatter.date(from: self) {
            return date
        } else {
            return nil
        }
    }
    
    func toTime() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm a"
        dateFormatter.timeZone = TimeZone(identifier: "KST")
        //        dateFormatter.locale = Locale(identifier: "ko_KR")
        if let date = dateFormatter.date(from: self) {
            
            return date
        } else {
            return nil
        }
    }
    
    func stringToInt() -> Int? {
        var str = self
        str.removeLast(3)
        str = str.replacingOccurrences(of: ":", with: "")
        
        return Int(str) ?? nil
    }
    
    func recurrenceTitleByPattern() -> Self {
        switch self {
        case "none":
            return "반복 안함"
        case "daily":
            return "매일"
        case let str where str.starts(with: "weekly"):
            let day = str.components(separatedBy: ":").last?.weekEngToKor() ?? ""
            return "매주 \(day)요일"
        case let str where str.starts(with: "monthly:date"):
            let date = str.components(separatedBy: ":").last ?? ""
            return "매월 \(date)일"
        case let str where str.starts(with: "monthly:nth_week"):
            let parts = str.components(separatedBy: ":")
            let nthWeek = parts.count >= 2 ? parts[2] : ""
            let day = parts.last?.weekEngToKor() ?? ""
            return "매월 \(nthWeek)번째 \(day)요일"
        case "weekday":
            return "평일마다(월-금)"
        default:
            return "Unknown pattern"
        }
    }
    
    func weekEngToKor() -> Self {
        switch self {
        case "Mon":
            return "월"
        case "Tue":
            return "화"
        case "Wed":
            return "수"
        case "Thu":
            return "목"
        case "Fri":
            return "금"
        case "Sat":
            return "토"
        case "Sun":
            return "일"
        default:
            return "Unknown day"
        }
    }
    
    func insertDatePeriod() -> Self {
        let year = self.prefix(4)
        let month = self.dropFirst(4).prefix(2)
        let day = self.suffix(2)
        
        return "\(year).\(month).\(day)"
    }
}
