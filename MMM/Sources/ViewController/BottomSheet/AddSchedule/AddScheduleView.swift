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
    @Environment(\.presentationMode) var presentationMode
    
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
//                        // 여기서 데이터 바인딩
                        addScheduleViewModel.getCurrentRadioButtonItem()
                        editViewModel.recurrenceTitle = addScheduleViewModel.addScheduleTapViewLabel
                        editViewModel.recurrenceInfo = addScheduleViewModel.recurrenceInfo
                        presentationMode.wrappedValue.dismiss()
                        print("확인 \(addScheduleViewModel.recurrenceInfo)")
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
                    RadioButtonGroup(items: addScheduleViewModel.radioButtonItems.map { $0.0 }, selectedId: "반복 안함") { selected in
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
                        isShowingSheet = true
                    } label: {
                        HStack(spacing: 8) {
                            Text(isTypeButtonOn ? addScheduleViewModel.recurrenceTypeText : "없음")
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
                AddScheduleRepetitionView(addScheduleViewModel: addScheduleViewModel, isShowingSheet: $isShowingSheet)
                Spacer()
            }
        }
        .onAppear {
            // 최초 date 값을 가져옴
            guard let date = editViewModel.date else { return }
            addScheduleViewModel.date = date
            addScheduleViewModel.recurrenceInfo.startYMD = date.getFormattedYMD()
        }
    }
}

#Preview {
    AddScheduleView(editViewModel: EditActivityViewModel(isAddModel: true))
}
