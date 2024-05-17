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
    @Environment(\.dismiss) var dismiss
    // 반복 안함일 경우에는 detail Sheet로 넘어가면 안되기 때문에 처리해줌
    private var isTypeButtonOn: Bool {
        addScheduleViewModel.selectedId != "반복 안함"
    }
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("일정 반복 추가")
                        .font(Font(R.Font.h5))
                    Spacer()
                    Button {
//                        // 확인 버튼을 눌렀을 경우에만 editVM에 데이터를 넣어줘야함
                        addScheduleViewModel.getCurrentRadioButtonItem()
                        editViewModel.recurrenceTitle = addScheduleViewModel.addScheduleTapViewLabel
                        editViewModel.recurrenceInfo = addScheduleViewModel.recurrenceInfo
                        dismiss()
//                        print("확인 \(addScheduleViewModel.recurrenceInfo)")
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
                    RadioButtonGroup(items: addScheduleViewModel.radioButtonItems.map { $0.0 }, selectedId: $addScheduleViewModel.selectedId) { selected in
                        // 확인 버튼을 눌렀을 경우에만 editVM에 데이터를 넣어줘야하기 떄문에 radio를 선택했을 경우 이벤트 처리 ㄴㄴ
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
        .sheet(isPresented: $isShowingSheet) {
            VStack {
                AddScheduleRepetitionView(addScheduleViewModel: addScheduleViewModel, isShowingSheet: $isShowingSheet)
                Spacer()
            }
            .presentationDetents([.fraction(0.5)])
        }
//        .halfSheet(showSheet: $isShowingSheet) {
//            VStack {
//                AddScheduleRepetitionView(addScheduleViewModel: addScheduleViewModel, isShowingSheet: $isShowingSheet)
//                Spacer()
//            }
//        }
        .onAppear {
            // recurrenceInfo가 있을 경우 그대로 addScheduleViewModel에 넣어줌
            if let recurrenceInfo = editViewModel.recurrenceInfo {
                // 20240401 이걸 date 형식으로 바꿔줘야함
                if let date = editViewModel.createAt.toDate() {
                    addScheduleViewModel.date = date
                    addScheduleViewModel.recurrenceInfo = recurrenceInfo
                    addScheduleViewModel.selectedId = recurrenceInfo.recurrencePattern.recurrenceTitleByPattern()
                }

            } else {
                // recurrenceInfo가 없을 경우(최초 진입) 데이터 직접 넣어줌, date값을 초기세팅해줌
                guard let date = editViewModel.date else { return }
                addScheduleViewModel.date = date
                addScheduleViewModel.recurrenceInfo.startYMD = date.getFormattedYMD()
                addScheduleViewModel.selectedId = "반복 안함"
            }
        }
    }
}

#Preview {
    AddScheduleView(editViewModel: EditActivityViewModel(isAddModel: true))
}
