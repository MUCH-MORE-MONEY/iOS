//
//  ScheduleRepetitionView.swift
//  MMM
//
//  Created by yuraMacBookPro on 2/15/24.
//

import SwiftUI

struct AddScheduleView: View {
    @State private var isShowingSheet: Bool = false
    @ObservedObject var editViewModel: EditActivityViewModel
    @StateObject var addScheduleViewModel = AddScheduleViewModel()
    
    private var items: [String] {
        [
            "반복 안함",
            "매일",
            "매주 \(addScheduleViewModel.recurrenceWeekday)요일",
            "매월 \(addScheduleViewModel.recurrenceDayofMonth)일",
            "매월 \(addScheduleViewModel.recurrenceWeekOfMonth)번째 \(addScheduleViewModel.recurrenceWeekday)요일",
            "주중 매일 (월-금)"
        ]
    }
    
    private var isTypeButtonOn: Bool {
        addScheduleViewModel.recurrenceRadioOption != "반복 안함"
    }
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("일정 반복 추가")
                        .font(Font(R.Font.h5))
                    Spacer()
                    Button {
                        // 여기서 데이터 바인딩 및 dismiss
                        print("확인")
                    } label: {
                        Text("확인")
                            .font(Font(R.Font.title3))
                            .foregroundStyle(Color(R.Color.black))
                    }
                }
                .padding(.top, 32)
                .padding(.bottom, 10)
                
                Group {
                    // 초기값을 "반복 안함"으로 설정
                    RadioButtonGroup(items: items, selectedId: "반복 안함") { selected in
                        addScheduleViewModel.recurrenceRadioOption = selected
                    }
                }.padding(.top, 12)

                Divider()
                    .padding(.top, 7)
                
                HStack {
                    Text("반복 종류")
                        .font(Font(R.Font.title1))
                        .foregroundStyle(isTypeButtonOn ? Color(R.Color.gray900) : Color(R.Color.gray400))
                    Spacer()
                    Button {
                        isShowingSheet.toggle()
                        print("반복 종류 버튼 tapped")
                    } label: {
                        HStack(spacing: 8) {
                            Text(isTypeButtonOn ? addScheduleViewModel.recurrenceType : "없음")
                                .font(Font(R.Font.body0))
                                .foregroundStyle(isTypeButtonOn ? Color(R.Color.gray500) : Color(R.Color.gray300))
                            Image(uiImage: R.Icon.iconArrowNextGray16)
                        }
                    }
                    .disabled(!isTypeButtonOn)
                }
                .padding([.top, .bottom], 11)
            }
            .padding([.leading, .trailing], 24)
            Spacer()
        }
        .halfSheet(showSheet: $isShowingSheet) {
            VStack {
                AddScheduleRepetitionView()
                Spacer()
            }
        }
        .onAppear {
            // 최초 date 값을 가져옴
            guard let date = editViewModel.date else { return }
            addScheduleViewModel.date = date
        }
    }
}

#Preview {
    AddScheduleView(editViewModel: EditActivityViewModel(isAddModel: true))
}
