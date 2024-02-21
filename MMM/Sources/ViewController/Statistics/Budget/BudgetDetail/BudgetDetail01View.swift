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
            Text("""
                            ***이번 달 수입***과 더불어
                            고정 지출과 예상 지출들을 고려하여
                            ***실천가능한 저축 목표***를 세워보세요!
                            """)
            .font(Font(R.Font.body0))
            .foregroundStyle(Color(R.Color.white))
            
            Image(uiImage: R.Icon.iconBudgetSettingCalendar)
                .padding(.top, 89)
        }
        .background(Color(R.Color.gray900))
        

    }
}

#Preview {
    BudgetDetail01View(budgetSettingViewModel: BudgetSettingViewModel())
}
