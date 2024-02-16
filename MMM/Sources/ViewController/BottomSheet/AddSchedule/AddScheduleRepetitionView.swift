//
//  AddScheduleRepetitionView.swift
//  MMM
//
//  Created by yuraMacBookPro on 2/16/24.
//

import SwiftUI

struct AddScheduleRepetitionView: View {
    let items = ["횟수", "날짜"]
    let times = [1,2,3,4,5]
    @State private var selectedID = "횟수"
    @State private var timeSelected = 1
    
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
                    RadioButton(items[0], callback: { id in
                        selectedID = id
                    }, selectedID: selectedID)
                    
                    if selectedID == items[0] {
                        Picker("selected student", selection: $timeSelected) {
                                    ForEach(0 ..< times.count) {
                                        Text("\(self.times[$0])")
                                    }
                        }.pickerStyle(.inline)

                    }
                    RadioButton(items[1], callback: { id in
                        selectedID = id
                    }, selectedID: selectedID)
                    
                    if selectedID == items[1] {
                        Picker("selected student", selection: $timeSelected) {
                                    ForEach(0 ..< times.count) {
                                        Text("\(self.times[$0])")
                                    }
                        }.pickerStyle(.inline)

                    }
                }
                

            }
            .padding([.leading, .trailing], 24)
            
        }.padding(.top, 12)
        Spacer()
    }
}


#Preview {
    AddScheduleRepetitionView()
}
