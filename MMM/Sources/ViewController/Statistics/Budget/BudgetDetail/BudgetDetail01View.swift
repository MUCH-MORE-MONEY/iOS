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
                Text("""
                                ***이번 달 수입***과 더불어
                                고정 지출과 예상 지출들을 고려하여
                                ***실천가능한 저축 목표***를 세워보세요!
                                """)
                .font(Font(R.Font.body0))
                .foregroundStyle(Color(R.Color.white))
                Spacer()
            }

            
            Image(uiImage: R.Icon.iconBudgetSettingCalendar)
                .padding(.top, 89)
            
            Spacer()
            
            TooltipView(text: "최근 설정한 지출 예산은 {0}만원이에요", color: R.Color.black.suColor)
                .padding(.top, 21)
            
            Button {
                
            } label: {
                Text("이전 예산 그대로 설정")
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: 56)
                
                    .font(Font(R.Font.title1))
                    .foregroundStyle(R.Color.gray100.suColor)
                    .background(R.Color.orange500.suColor)
            }
            .padding(.top, 12)
//            .padding([.leading, .trailing, .bottom], 24)
    
        }
    }
}

#Preview {
    BudgetDetail01View(budgetSettingViewModel: BudgetSettingViewModel())
}
