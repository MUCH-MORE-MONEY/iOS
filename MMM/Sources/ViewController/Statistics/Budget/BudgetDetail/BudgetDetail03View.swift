//
//  BudgetDetail03View.swift
//  MMM
//
//  Created by yuraMacBookPro on 2/23/24.
//

import SwiftUI
import Combine

struct BudgetDetail03View: View {
    @ObservedObject var budgetSettingViewModel: BudgetSettingViewModel
    @State private var price = 100.0
    
    private var priceText: String {
        get {
            return "\(Int(price))"
        }
    }
    
    let content = ["전문가들이 추천하는 저축률이에요.\n시드머니가 필요한 사회초년생에게 적합해요.",
                   " 권장 저축률보다 목표가 낮아요.\n이번 달 큰 소비 계획이 있으신가 봐요.",
                   "가급적 이 정도는 저축하는 것을 추천해요.\n목표가 높으면 더 좋고요!",
                   "이 기세라면 돈을 빠르게 모을 수 있어요.\n꾸준히 종잣돈을 모아봐요.",
                   "경제적 자립에 한 발짝 다가갈 수 있어요.\n절약을 응원할게요!"]
    
    var body: some View {
        VStack {
            HStack {
                Text("수입의 얼마를 모으실 건가요?")
                    .font(Font(R.Font.regular20))
                    .foregroundStyle(Color(R.Color.gray200))
                    .padding(.bottom, 136)
                Spacer()
            }

            Text("\(priceText)만원")
                .font(Font(R.Font.h2))
                .foregroundStyle(Color(R.Color.white))
                .padding(.bottom, 22)
            
            Text(content[0])
                .multilineTextAlignment(.center)
                .font(Font(R.Font.medium14))
                .foregroundStyle(Color(R.Color.orange100))
                .padding(.bottom, 32)
            
            Button {
                debugPrint("직접 입력하기 tapped")
            } label: {
                Text("직접 입력하기")
                    .underline()
                    .font(Font(R.Font.body3))
                    .foregroundStyle(Color(R.Color.gray500))
            }

            Spacer()
            
            // 툴팁으로 사용될 텍스트 뷰
            Text("\(priceText)%")
                .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .background(Color(R.Color.orange500))
                .font(Font(R.Font.body1))
                .foregroundStyle(Color(R.Color.white))
                .cornerRadius(8)
//                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.blue, lineWidth: 2))
                .offset(x: 0, y: -30) // 툴팁 위치 조정
            // 슬라이더 값에 따라 툴팁 위치 동적 조정
                .offset(x: CGFloat((price - 100)), y: 0) // 가정: 슬라이더 너비가 300pt

            BudgetSlider(value: $price, range: 0...200)

        }
    }
}

#Preview {
    BudgetDetail03View(budgetSettingViewModel: BudgetSettingViewModel())
}
