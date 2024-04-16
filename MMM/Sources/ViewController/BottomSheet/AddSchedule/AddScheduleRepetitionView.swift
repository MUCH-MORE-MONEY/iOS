//
//  AddScheduleRepetitionView.swift
//  MMM
//
//  Created by yuraMacBookPro on 2/16/24.
//

import SwiftUI

struct AddScheduleRepetitionView: View {
    @ObservedObject var addScheduleViewModel: AddScheduleViewModel
    @State private var timeSelected = 1
    @State private var isFirst = true
    @Binding var isShowingSheet: Bool
        
    private let radioButtonItems = ["횟수", "날짜"]
    private let times = [1,2,3,4,5]
    @State private var selectedID = "횟수"
    
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    @State private var selectedDay: Int = Calendar.current.component(.day, from: Date())
    @Environment(\.presentationMode) var presentationMode
    
    // 년도, 월, 일 범위 설정
    let years: [Int] = Array(2020...2024)
    let months: [Int] = Array(1...12)
    var days: [Int] {
        let selectedMonthIndex = selectedMonth - 1
        let daysInMonth = Calendar.current.range(of: .day, in: .month, for: Calendar.current.date(from: DateComponents(year: selectedYear, month: selectedMonthIndex))!)!
        return Array(daysInMonth)
    }
    
    private var isTimeRadioButtonOn: Bool {
        selectedID == radioButtonItems[0]
    }
    
    private var nextYear: Date {
        Calendar.current.date(byAdding: .year, value: 1, to: addScheduleViewModel.startDate)!
    }
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("일정 반복 추가")
                        .font(Font(R.Font.h5))
                    Spacer()
                    Button {
                        if isTimeRadioButtonOn {
                            addScheduleViewModel.recurrenceInfo.recurrenceEndDvcd = "01"
                            
                        } else {
                            addScheduleViewModel.recurrenceInfo.recurrenceEndDvcd = "02"
                            addScheduleViewModel.recurrenceInfo.startYMD = addScheduleViewModel.startDate.getFormattedYMD()
                            addScheduleViewModel.recurrenceInfo.endYMD = addScheduleViewModel.selectedDate?.getFormattedYMD() ?? ""
                            addScheduleViewModel.recurrenceInfo.recurrenceCnt = 0
                        }

                        presentationMode.wrappedValue.dismiss()
                        isShowingSheet = false
                    } label: {
                        Text("확인")
                            .font(Font(R.Font.title3))
                            .foregroundStyle(Color(R.Color.black))
                    }
                    
                }
                .padding(.top, 32)
                .padding(.bottom, 10)
                .padding([.leading, .trailing], 24)
                
                
                RadioButton(radioButtonItems[0],
                            selectedID: selectedID,
                            subLabel: isTimeRadioButtonOn ? "\(addScheduleViewModel.recurrenceInfo.recurrenceCnt)회 반복" : nil,
                            callback: { id in
                    selectedID = id
                    isFirst = false
                })
                
                .padding([.leading, .trailing], 24)

                if !isFirst && selectedID == radioButtonItems[0] {
                    HStack {
                        Picker(selection: $addScheduleViewModel.recurrenceInfo.recurrenceCnt, label: Text("회").fixedSize()) {
                            ForEach(times, id: \.self) {
                                Text("\($0)")
                            }
                        }
                        .pickerStyle(.wheel)
                        Text("회")
                            .font(Font(R.Font.h6))
                    }
                    .padding([.trailing], 112)
                    .background(Color(R.Color.gray100))
                    
                }
                RadioButton(radioButtonItems[1],
                            selectedID: selectedID,
                            subLabel: isTimeRadioButtonOn ? nil : "\(addScheduleViewModel.selectedDate?.getFormattedYMDByCalendar() ?? "")까지",
                            callback: { id in
                    selectedID = id
                    isFirst = false
                })
                .padding([.leading, .trailing], 24)
                
                if selectedID == radioButtonItems[1] {
                    VStack { // 여기서 endDate는 종료기간임
                        DatePickerRepresentable(selectedDate: $addScheduleViewModel.selectedDate, range: addScheduleViewModel.startDate...nextYear)
                            .frame(width: UIScreen.width, height: 168)
                            .background(Color(R.Color.gray100))
                        
                        // 기본 피커
//                        DatePicker(selection: $addScheduleViewModel.endDate,
//                                   in: addScheduleViewModel.date...nextYear,
//                                   displayedComponents: .date) {
//                            
//                        }
//                        .labelsHidden()
//                        .frame(width: UIScreen.width, height: 168)
//                        .background(Color(R.Color.gray100))
//                        .clipped()
//                        .datePickerStyle(.wheel)
                    }
                }
            }
        }
        .ignoresSafeArea()
        Spacer()
    }
}

struct AddScheduleRepetitionView_Previews: PreviewProvider {
    @State static var isShowingSheet = true
    static var previews: some View {
        AddScheduleRepetitionView(addScheduleViewModel: AddScheduleViewModel(), isShowingSheet: $isShowingSheet)
    }
}
