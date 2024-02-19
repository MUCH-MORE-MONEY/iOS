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
    @State private var selectedID = "날짜"
    @State private var timeSelected = 1
    @State private var date = Date()
    
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
                .padding([.leading, .trailing], 24)
                
                RadioButton(items[0], callback: { id in
                    selectedID = id
                }, selectedID: selectedID)
                .padding([.leading, .trailing], 24)
                
                if selectedID == items[0] {
                    HStack {
                        Picker(selection: $timeSelected, label: Text("회").fixedSize()) {
                            
                            ForEach(0 ..< times.count) {
                                Text("\(self.times[$0])")
                            }
                        }
                        .pickerStyle(.wheel)
                        Text("회")
                            .font(Font(R.Font.h6))
                    }
                    .padding([.trailing], 112)
                    .background(Color(R.Color.gray100))
                    
                }
                RadioButton(items[1], callback: { id in
                    selectedID = id
                }, selectedID: selectedID)
                .padding([.leading, .trailing], 24)
                
                if selectedID == items[1] {
                    
                    VStack {
                        DatePicker(selection: $date, displayedComponents: .date) {
                            
                        }
                        .labelsHidden()
                        .frame(width: UIScreen.width, height: 168)
                        .background(Color(R.Color.gray100))
                        .clipped()
                        .datePickerStyle(.wheel)
                    }
                }
            }
        }
        .ignoresSafeArea()
        Spacer()
    }
}


#Preview {
    AddScheduleRepetitionView()
}
