//
//  DatePickerRepresentable.swift
//  MMM
//
//  Created by yuraMacBookPro on 4/5/24.
//

import SwiftUI
import UIKit

import SwiftUI
import UIKit

struct DatePickerRepresentable: UIViewRepresentable {
    @Binding var selectedDate: Date?
    let range: ClosedRange<Date>

    func makeUIView(context: Context) -> UIPickerView {
        let picker = UIPickerView()
        picker.delegate = context.coordinator
        picker.dataSource = context.coordinator
        return picker
    }

    func updateUIView(_ picker: UIPickerView, context: Context) {
        // 선택된 날짜로 UIPickerView를 업데이트
        let selectedComponents = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate ?? Date())
        let selectedYear = selectedComponents.year ?? Calendar.current.component(.year, from: Date())
        let selectedMonth = selectedComponents.month ?? Calendar.current.component(.month, from: Date())
        let selectedDay = selectedComponents.day ?? Calendar.current.component(.day, from: Date())

        // Coordinator를 통해 년, 월, 일 데이터를 업데이트
        context.coordinator.updateMonths(for: selectedYear)
        context.coordinator.updateDays(for: selectedYear, month: selectedMonth)

        // UIPickerView에 현재 선택된 년, 월, 일을 반영
        if let yearIndex = context.coordinator.years.firstIndex(of: selectedYear) {
            picker.selectRow(yearIndex, inComponent: 0, animated: true)
        }
        if let monthIndex = context.coordinator.months.firstIndex(of: selectedMonth) {
            picker.reloadComponent(1)
            picker.selectRow(monthIndex, inComponent: 1, animated: true)
        }
        if let dayIndex = context.coordinator.days.firstIndex(of: selectedDay) {
            picker.reloadComponent(2)
            picker.selectRow(dayIndex, inComponent: 2, animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        var parent: DatePickerRepresentable
        var years: [Int] = []
        var months: [Int] = Array(1...12)
        var days: [Int] = Array(1...31)

        init(_ pickerView: DatePickerRepresentable) {
            self.parent = pickerView
            self.years = Array(Calendar.current.component(.year, from: pickerView.range.lowerBound)...Calendar.current.component(.year, from: pickerView.range.upperBound))
        }

        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            3
        }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            switch component {
            case 0:
                return years.count
            case 1:
                return months.count
            case 2:
                return days.count
            default:
                return 0
            }
        }

        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            switch component {
            case 0:
                return "\(years[row])년"
            case 1:
                return "\(months[row])월"
            case 2:
                return "\(days[row])일"
            default:
                return nil
            }
        }

        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            let selectedYear = years[pickerView.selectedRow(inComponent: 0)]
            let selectedMonth = months[pickerView.selectedRow(inComponent: 1)]
            let selectedDay = days[pickerView.selectedRow(inComponent: 2)]

            var shouldReloadDays = false

            if component == 0 {  // Year changed
                updateMonths(for: selectedYear)
                pickerView.reloadComponent(1)
                pickerView.selectRow(0, inComponent: 1, animated: false)
                shouldReloadDays = true
            } else if component == 1 {  // Month changed
                shouldReloadDays = true
            }

            if shouldReloadDays {
                let previousDayCount = days.count
                updateDays(for: selectedYear, month: selectedMonth)
                if previousDayCount != days.count {
                    pickerView.reloadComponent(2)
                    if selectedDay > days.count {
                        pickerView.selectRow(days.count - 1, inComponent: 2, animated: false)
                    } else {
                        pickerView.selectRow(selectedDay - 1, inComponent: 2, animated: false)
                    }
                }
            }

            updateSelectedDate(pickerView: pickerView)
        }
        
        private func updateSelectedDate(pickerView: UIPickerView) {
            let selectedYear = years[pickerView.selectedRow(inComponent: 0)]
            let selectedMonth = months[pickerView.selectedRow(inComponent: 1)]
            let selectedDay = days[min(pickerView.selectedRow(inComponent: 2), days.count - 1)]

            let dateComponents = DateComponents(year: selectedYear, month: selectedMonth, day: selectedDay)
            if let newDate = Calendar.current.date(from: dateComponents) {
                parent.selectedDate = newDate
            }
        }
        
        func updateMonths(for year: Int) {
            let calendar = Calendar.current
            let startYear = calendar.component(.year, from: parent.range.lowerBound)
            let endYear = calendar.component(.year, from: parent.range.upperBound)
            let startMonth = (year == startYear) ? calendar.component(.month, from: parent.range.lowerBound) : 1
            let endMonth = (year == endYear) ? calendar.component(.month, from: parent.range.upperBound) : 12
            months = Array(startMonth...endMonth)
        }

        func updateDays(for year: Int, month: Int) {
            let calendar = Calendar.current
            
            // 존재하는 날짜인지 확인하기 위해 유효한 날짜를 생성
            guard let validDate = calendar.date(from: DateComponents(year: year, month: month)) else {
                days = []
                return
            }
            
            let range = calendar.range(of: .day, in: .month, for: validDate) ?? Range(1...28)

            let startComponents = calendar.dateComponents([.year, .month, .day], from: parent.range.lowerBound)
            let endComponents = calendar.dateComponents([.year, .month, .day], from: parent.range.upperBound)

            let startDay = (year == startComponents.year && month == startComponents.month) ? max(startComponents.day!, 1) : 1
            let endDay = (year == endComponents.year && month == endComponents.month) ? min(endComponents.day!, range.upperBound) : range.upperBound

            days = Array(startDay..<endDay)
        }
    }
}
