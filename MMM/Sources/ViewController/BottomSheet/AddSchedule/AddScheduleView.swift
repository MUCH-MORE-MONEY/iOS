//
//  ScheduleRepetitionView.swift
//  MMM
//
//  Created by yuraMacBookPro on 2/15/24.
//

import SwiftUI

struct AddScheduleView: View {
    @State private var isShowingSheet: Bool = false
    
    let items = ["반복 안함", "매일", "매주 {월}요일", "매월 {15}일", "매월 {3}번째 {월}요일", "주중 매일 (월-금)"]
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("일정 반복 추가")
                        .font(Font(R.Font.h5))
                    Spacer()
                    Button {
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
                    RadioButtonGroup(items: items, selectedId: "반복 안함") { selected in
                        print("Selected \(selected)")
                    }
                }.padding(.top, 12)

                Divider()
                    .padding(.top, 7)
                
                HStack {
                    Text("반복 종류")
                        .font(Font(R.Font.title1))
                        .foregroundStyle(Color(R.Color.gray400))
                    Spacer()
                    Button {
                        isShowingSheet.toggle()
                        print("반복 종류 버튼 tapped")
                    } label: {
                        HStack(spacing: 8) {
                            Text("없음")
                                .font(Font(R.Font.body0))
                                .foregroundStyle(Color(R.Color.gray300))
                            Image(uiImage: R.Icon.iconArrowNextGray16)
                        }
                    }
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
    }
}

#Preview {
    AddScheduleView()
}
