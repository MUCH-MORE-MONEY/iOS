//
//  CustomCalendarView.swift
//  MMM
//
//  Created by yuraMacBookPro on 4/5/24.
//

import SwiftUI
import UIKit

final class DateComponentViewModel: ObservableObject {
    var baseDate: Date
    var calendar: Calendar
    
    init(baseDate: Date, calendar: Calendar = Calendar.current) {
        self.baseDate = baseDate
        self.calendar = calendar
    }

    // 날짜 컴포넌트의 범위를 계산하는 로직
    func yearRange() -> [Int] {
        let baseYear = calendar.component(.year, from: baseDate)
        return [baseYear, baseYear + 1]
    }
    
    func monthRange(forYear year: Int) -> [Int] {
        let baseYear = calendar.component(.year, from: baseDate)
        let baseMonth = calendar.component(.month, from: baseDate)
        
        if year > baseYear {
            return Array(1...(baseMonth - 1))
        } else {
            return Array(baseMonth...12)
        }
    }
    
    func dayRange(forYear year: Int, month: Int) -> [Int] {
        // 계산은 단순화를 위해 생략. 실제 구현에는 선택된 년, 월에 따라 일자 범위 계산 필요.
        return Array(1...31)
    }
}

// UIPickerView를 SwiftUI에서 사용하기 위한 래퍼 뷰
struct DatePickerView: UIViewRepresentable {
    
    @ObservedObject var viewModel: DateComponentViewModel
//    @ObservedObject var viewModel: PickerViewModel

    func makeUIView(context: Context) -> UIPickerView {
        let picker = UIPickerView()
        picker.delegate = context.coordinator
        picker.dataSource = context.coordinator
        return picker
    }

    func updateUIView(_ uiView: UIPickerView, context: Context) {
        // 예시로, 현재 날짜를 기준으로 UIPickerView를 업데이트합니다.
        let date = viewModel.baseDate
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)

        let year = components.year!
        let month = components.month!
        let day = components.day!
        
        uiView.selectRow(year - 2020, inComponent: 0, animated: true)
        uiView.selectRow(month - 1, inComponent: 1, animated: true)
        uiView.selectRow(day - 1, inComponent: 2, animated: true)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self, viewModel: viewModel)
    }

    class Coordinator: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
        var parent: DatePickerView
        var viewModel: DateComponentViewModel

        init(_ pickerView: DatePickerView, viewModel: DateComponentViewModel) {
            self.parent = pickerView
            self.viewModel = viewModel
        }

        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 3 // 년, 월, 일
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            switch component {
            case 0:
                return viewModel.yearRange().count
            case 1:
                let selectedYearIndex = pickerView.selectedRow(inComponent: 0)
                let years = viewModel.yearRange()
                let selectedYear = years[selectedYearIndex]
                return viewModel.monthRange(forYear: selectedYear).count
            case 2:
                // 일자 계산 로직은 선택된 년, 월에 따라 다릅니다.
                return 31
            default:
                return 0
            }
        }

        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            switch component {
            case 0:
                let year = viewModel.yearRange()[row]
                return "\(year)년"
            case 1:
                let selectedYearIndex = pickerView.selectedRow(inComponent: 0)
                let years = viewModel.yearRange()
                let selectedYear = years[selectedYearIndex]
                let month = viewModel.monthRange(forYear: selectedYear)[row]
                return "\(month)월"
            case 2:
                return "\(row + 1)일" // 간단화를 위해
            default:
                return nil
            }
        }

        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            let date = viewModel.baseDate
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day], from: date)

            var year = components.year!
            var month = components.month!
            var day = components.day!
            
            switch component {
            case 0:
                year = 2020 + row
            case 1:
                month = row + 1
            case 2:
                day = row + 1
            default:
                break
            }
            pickerView.reloadAllComponents() // 선택에 따라 다른 컴포넌트의 범위가 변경될 수 있으므로 전체 갱신
        }
    }
}



struct CustomCalendarView: View {
    @StateObject private var viewModel = DateComponentViewModel(baseDate: Date())

    var body: some View {
        DatePickerView(viewModel: viewModel)
    }
}

#Preview {
    CustomCalendarView()
}

