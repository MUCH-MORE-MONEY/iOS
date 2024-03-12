//
//  AddScheduleViewModel.swift
//  MMM
//
//  Created by yuraMacBookPro on 3/12/24.
//

import Foundation
import Combine

final class AddScheduleViewModel: ObservableObject {
    @Published var date = Date()
    // 경제활동 반복
    @Published var recurrenceInfo: [APIParameters.RecurrenceInfo] = []
    @Published var recurrenceRadioOption = "반복 안함"
    @Published var recurrenceType = "4회 반복"
    
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
    
}
