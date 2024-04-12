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
        
        var components = DateComponents()
        components.year = year
        components.month = month
        
        // 지정된 월의 첫 날을 구성합니다.
        if let date = calendar.date(from: components) {
            // 지정된 월의 마지막 날짜를 얻기 위해 다음 달의 첫 날에서 하루를 빼줍니다.
            let range = calendar.range(of: .day, in: .month, for: date)!
            return Array(range)
        } else {
            // 오류 상황에 대한 기본 처리, 실제 구현에서는 오류 처리 방식을 고려해야 합니다.
            return []
        }
    }
}

// UIPickerView를 SwiftUI에서 사용하기 위한 래퍼 뷰
struct DatePickerView: UIViewRepresentable {
    
    @ObservedObject var viewModel: DateComponentViewModel
//    @ObservedObject var viewModel: PickerViewModel
    @ObservedObject var addScheduleViewModel: AddScheduleViewModel
    @Binding var selectedDate: Date
    
    func makeUIView(context: Context) -> UIPickerView {
//        viewModel.baseDate = addScheduleViewModel.date
        
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
        
        uiView.selectRow(year, inComponent: 0, animated: true)
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
                let selectedYearIndex = pickerView.selectedRow(inComponent: 0)
                let selectedMonthIndex = pickerView.selectedRow(inComponent: 1)
                let years = viewModel.yearRange()
                let months = viewModel.monthRange(forYear: years[selectedYearIndex])
                
                // 선택된 연도와 월을 기준으로 일자 수 계산
                if !years.isEmpty && !months.isEmpty {
                    let selectedYear = years[selectedYearIndex]
                    let selectedMonth = months[selectedMonthIndex]
                    return viewModel.dayRange(forYear: selectedYear, month: selectedMonth).count
                }
                return 0
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

            let calendar = Calendar.current
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: parent.selectedDate)

            switch component {
            case 0:
                dateComponents.year = 2020 + row
            case 1:
                dateComponents.month = row + 1
            case 2:
                dateComponents.day = row + 1
            default:
                break
            }
            
            if let newDate = Calendar.current.date(from: dateComponents) {
                parent.selectedDate = newDate
            }
            
            pickerView.reloadAllComponents() // 선택에 따라 다른 컴포넌트의 범위가 변경될 수 있으므로 전체 갱신
        }
    }
}



struct CustomCalendarView: View {
    @Binding var selectedDate: Date
    @StateObject private var viewModel = DateComponentViewModel(baseDate: Date())
    @ObservedObject var addScheduleViewModel: AddScheduleViewModel
    
    var body: some View {
        DatePickerView(viewModel: viewModel, addScheduleViewModel: addScheduleViewModel, selectedDate: $selectedDate)
    }
}

//#Preview {
//    CustomCalendarView(selectedDate: <#Date#>, addScheduleViewModel: AddScheduleViewModel())
//}

