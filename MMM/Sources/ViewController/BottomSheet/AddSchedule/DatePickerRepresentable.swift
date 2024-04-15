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
    @Binding var selectedDate: Date
    let range: ClosedRange<Date>

    func makeUIView(context: Context) -> UIPickerView {
        let picker = UIPickerView()
        picker.delegate = context.coordinator
        picker.dataSource = context.coordinator
        return picker
    }

    func updateUIView(_ picker: UIPickerView, context: Context) {
        print("selectedDate : \(selectedDate)")
        context.coordinator.updatePickerView(picker, with: selectedDate)
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
            var components = Calendar.current.dateComponents([.year, .month, .day], from: parent.selectedDate)
            switch component {
            case 0:
                components.year = years[row]
            case 1:
                components.month = months[row]
            case 2:
                components.day = days[row]
            default:
                break
            }
            if let newDate = Calendar.current.date(from: components) {
                parent.selectedDate = newDate
            }
        }

        func updatePickerView(_ picker: UIPickerView, with date: Date) {
            let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
            if let yearIndex = years.firstIndex(of: components.year ?? years.first!) {
                picker.selectRow(yearIndex, inComponent: 0, animated: true)
            }
            if let monthIndex = months.firstIndex(of: components.month ?? months.first!) {
                picker.selectRow(monthIndex, inComponent: 1, animated: true)
            }
            if let dayIndex = days.firstIndex(of: components.day ?? days.first!) {
                picker.selectRow(dayIndex, inComponent: 2, animated: true)
            }
        }
    }
}
