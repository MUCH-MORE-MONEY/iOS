//
//  ScheduleRepetitionView.swift
//  MMM
//
//  Created by yuraMacBookPro on 2/15/24.
//

import SwiftUI

struct AddScheduleView: View {
    let items = ["반복 안함", "매일", "매주 {월}요일", "매월 {15}일", "매월 {3}번째 {월}요일", "주중 매일 (월-금)"]
    
    var body: some View {
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
    }
}

struct RadioButton: View {

    @Environment(\.colorScheme) var colorScheme

    let id: String
    let callback: (String)->()
    let selectedID : String

    var isSelected: Bool {
        get {
            return selectedID == id
        }
    }
    
    init(_ id: String, callback: @escaping (String)->(), selectedID: String) {
        self.id = id
        self.selectedID = selectedID
        self.callback = callback
    }
    
    var body: some View {
        Button {
            callback(self.id)
        } label: {
            HStack(alignment: .center, spacing: 8) {
                
                Image(uiImage: (isSelected ? R.Icon.iconRadiobuttonActive : R.Icon.iconRadiobuttonEnable) ?? UIImage())
                Text(id)
                    .font(Font(isSelected ? R.Font.medium1 : R.Font.body0))
                    .foregroundStyle(Color(isSelected ? R.Color.gray800 : R.Color.gray600))
                Spacer()
            }
        }
        .padding([.top, .bottom], 11)
    }
}

struct RadioButtonGroup: View {
    let items: [String]
    @State var selectedId: String = ""
    let callback: (String) -> ()
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(items, id: \.self) { id in
                RadioButton(id, callback: radioGroupCallback, selectedID: selectedId)
                    .padding(0)
            }
        }
    }
    
    func radioGroupCallback(id: String) {
        selectedId = id
        callback(id)
    }
}

#Preview {
    AddScheduleView()
}
