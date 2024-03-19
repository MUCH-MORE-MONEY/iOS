//
//  AddScheduleViewModel.swift
//  MMM
//
//  Created by yuraMacBookPro on 3/12/24.
//

import Foundation
import Combine

final class AddScheduleViewModel: ObservableObject {
    enum RecurrencePattern {
        case none
        case daily
        case weekly
        case monthlyDate
        case monthlyNthWeek
        case weekday
    }
    
    @Published var date = Date()
    // 경제활동 반복
    @Published var recurrenceInfo: APIParameters.RecurrenceInfo = .init(
        endYMD: "",
        recurrenceCnt: 4,
        recurrenceEndDvcd: "01",        // 초기 세팅은 횟수반복이기 때문에 "01" 로 설정
        recurrencePattern: "none",      // 초기 세팅 none
        startYMD: "")
    @Published var recurrenceRadioOption = "반복 안함"
    @Published var endDate = Date()
    
    var dateComponent: DateComponents {
        let calendar = Calendar.current
        
        return calendar.dateComponents([.year, .month, .day, .weekday, .weekOfMonth], from: self.date)
    }
    
    var recurrenceWeekday: String {
        return date.getFormattedDate(format: "E")
    }
    
    var recurrenceMonth: String {
        return date.getFormattedDate(format: "MMMM")
    }
    
    var recurrenceDayofMonth: String {
        return "\(self.dateComponent.day ?? 1)"
    }
    
    var recurrenceWeekOfMonth: String {
        return "\(self.dateComponent.weekOfMonth ?? 1)"
    }
    
    var endYMDString: String {
        recurrenceInfo.endYMD
    }
    
    var radioButtonItems: [(String, RecurrencePattern)] {
        [
            ("반복 안함", .none),
            ("매일", .daily),
            ("매주 \(recurrenceWeekday)요일", .weekly),
            ("매월 \(recurrenceDayofMonth)일", .monthlyDate),
            ("매월 \(recurrenceWeekOfMonth)번째 \(recurrenceWeekday)요일", .monthlyNthWeek),
            ("주중 매일 (월-금)", .weekday)
        ]
    }
    
    var recurrenceTypeText: String {
        if recurrenceInfo.recurrenceEndDvcd == "01" {
            return "\(recurrenceInfo.recurrenceCnt)회 반복"
        } else {
            let date = recurrenceInfo.endYMD
            
            let year = date.prefix(4)
            let month = date.dropFirst(4).prefix(2)
            let day = date.suffix(2)
            
            return "\(year).\(month).\(day)까지"
        }
    }
    
    var addScheduleTapViewLabel: String {
        let item = radioButtonItems.filter { $0.0 == recurrenceRadioOption }.first ?? radioButtonItems[0]

        return item.0 + ", \(recurrenceTypeText)"
    }
    
    func getCurrentRadioButtonItem() {
        // 여기서 데이터 바인딩
        let item = radioButtonItems.filter { $0.0 == recurrenceRadioOption }.first ?? radioButtonItems[0]
        switch item.1 {
        case .none:
            recurrenceInfo.recurrencePattern = "none"
        case .daily:
            recurrenceInfo.recurrencePattern = "daily"
        case .weekly:
            let day = date.getFormattedDateENG(format: "EEE")
            recurrenceInfo.recurrencePattern = "weekly:\(day)"
        case .monthlyDate:
            recurrenceInfo.recurrencePattern = "monthly:date:\(recurrenceDayofMonth)"
        case .monthlyNthWeek:
            let day = date.getFormattedDateENG(format: "EEE")
            recurrenceInfo.recurrencePattern = "monthly:nth_week:\(recurrenceWeekOfMonth):\(day)"
        case .weekday:
            recurrenceInfo.recurrencePattern = "weekday"
        }
    }
}
