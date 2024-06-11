//
//  TooltipView.swift
//  MMM
//
//  Created by yuraMacBookPro on 4/17/24.
//

import SwiftUI

struct TooltipView: View {
    var text: String
    var color: Color
    
    var body: some View {
        // 툴팁으로 사용될 텍스트 뷰
        ZStack(alignment: .bottom) {
            Text(text)
                .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .background(color)
                .font(Font(R.Font.body1))
                .foregroundStyle(Color(R.Color.white))
                .cornerRadius(8)
            
            Rectangle()
                .fill(color)
                .frame(width: 12, height: 12)
                .rotationEffect(.degrees(45))
                .offset(y: 6)
        }

    }
}

#Preview {
    TooltipView(text: "100", color: R.Color.orange500.suColor)
}
