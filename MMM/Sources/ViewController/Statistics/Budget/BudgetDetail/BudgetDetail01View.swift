//
//  BudgetDetail01View.swift
//  MMM
//
//  Created by yuraMacBookPro on 2/21/24.
//

import SwiftUI

struct BudgetDetail01View: View {
    @ObservedObject var budgetSettingViewModel: BudgetSettingViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text("내가 고정적으로 쓰는 돈을 고려하여\n**이번 달의 수입**과 **저축할 금액**을 적고\n매일 ")
                    .font(Font(R.Font.h6)) // 일관된 폰트 적용
                    .foregroundColor(R.Color.white.suColor) +
                Text("**얼마 지출할 수 있는지**")
                    .font(Font(R.Font.h6)) // 같은 폰트로 유지
                    .foregroundColor(R.Color.yellow300.suColor) + // 변경하고자 하는 색상 적용
                Text(" 알아보세요!")
                    .font(Font(R.Font.h6))
                    .foregroundColor(R.Color.white.suColor)
                Spacer()
            }
            
            
            Image(uiImage: R.Icon.iconBudgetSettingCalendar)
                .padding(.top, 89)
            
            Spacer()
            
//            TooltipView(text: "최근 설정한 지출 예산은 {0}만원이에요", color: R.Color.black.suColor)
//                .padding(.top, 21)
            
//            Button {
//                
//            } label: {
//                Text("이전 예산 그대로 설정")
//                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: 56)
//                
//                    .font(Font(R.Font.title1))
//                    .foregroundStyle(R.Color.gray100.suColor)
//                    .background(R.Color.orange500.suColor)
//            }
//            .padding(.top, 12)
            //            .padding([.leading, .trailing, .bottom], 24)
            
        }
    }
}

#Preview {
    BudgetDetail01View(budgetSettingViewModel: BudgetSettingViewModel(budget: Budget.getDummy(), dateYM: "202404"))
}
