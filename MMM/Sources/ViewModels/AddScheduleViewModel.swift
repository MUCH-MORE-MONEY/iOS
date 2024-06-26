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
    
    @Published var startDate = Date()    // date picker의 시작 날짜를 정의 (현재 날짜 기준으로 start)
    @Published var selectedDate: Date? // 경제활동 반복을 종료할 날짜 -> selectedDate
    @Published var selectedId = ""
    // 경제활동 반복
    @Published var recurrenceInfo: APIParameters.RecurrenceInfo = .init(
        endYMD: "",
        recurrenceCnt: 4,
        recurrenceEndDvcd: "01",        // 초기 세팅은 횟수반복이기 때문에 "01" 로 설정
        recurrencePattern: "none",      // 초기 세팅 none
        startYMD: "")

    var dateComponent: DateComponents {
        let calendar = Calendar.current
        
        return calendar.dateComponents([.year, .month, .day, .weekday, .weekOfMonth], from: self.startDate)
    }
    
    var recurrenceWeekday: String {
        return startDate.getFormattedDate(format: "E")
    }
    
    var recurrenceMonth: String {
        return startDate.getFormattedDate(format: "MMMM")
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
            ("평일마다(월-금)", .weekday)
        ]
    }
    
    var recurrenceTypeText: String {
        if recurrenceInfo.recurrenceEndDvcd == "01" {
            return "\(recurrenceInfo.recurrenceCnt)회 반복"
        } else {
            return "\(recurrenceInfo.endYMD.insertDatePeriod())까지" 
        }
    }
    
    var addScheduleTapViewLabel: String {
        let item = radioButtonItems.filter { $0.0 == selectedId }.first ?? radioButtonItems[0]

        return item.0 + ", \(recurrenceTypeText)"
    }
    
    func getCurrentRadioButtonItem() {
        // 여기서 데이터 바인딩
        let item = radioButtonItems.filter { $0.0 == selectedId }.first ?? radioButtonItems[0]
        switch item.1 {
        case .none:
            recurrenceInfo.recurrencePattern = "none"
        case .daily:
            recurrenceInfo.recurrencePattern = "daily"
        case .weekly:
            let day = startDate.getFormattedDateENG(format: "EEE")
            recurrenceInfo.recurrencePattern = "weekly:\(day)"
        case .monthlyDate:
            recurrenceInfo.recurrencePattern = "monthly:date:\(recurrenceDayofMonth)"
        case .monthlyNthWeek:
            let day = startDate.getFormattedDateENG(format: "EEE")
            recurrenceInfo.recurrencePattern = "monthly:nth_week:\(recurrenceWeekOfMonth):\(day)"
        case .weekday:
            recurrenceInfo.recurrencePattern = "weekday"
        }
    }
}
