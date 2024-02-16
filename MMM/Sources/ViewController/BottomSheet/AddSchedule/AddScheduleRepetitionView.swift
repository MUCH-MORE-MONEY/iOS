//
//  AddScheduleRepetitionView.swift
//  MMM
//
//  Created by yuraMacBookPro on 2/16/24.
//

import SwiftUI

struct AddScheduleRepetitionView: View {
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
        }
        .padding([.leading, .trailing], 24)
    }
}

#Preview {
    AddScheduleRepetitionView()
}
