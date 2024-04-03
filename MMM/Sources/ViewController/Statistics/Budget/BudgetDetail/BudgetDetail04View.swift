//
//  BudgetDetail04View.swift
//  MMM
//
//  Created by yuraMacBookPro on 2/23/24.
//

import SwiftUI

struct BudgetDetail04View: View {
    @ObservedObject var budgetSettingViewModel: BudgetSettingViewModel
    
    let title = "일별 환산된 적정 지출 금액을\n달력에서 확인하시겠어요?"
    let subTitle = "월 지출 예산을 일별로 환산하면 다음과 같아요."
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text(title)
                .font(Font(R.Font.regular20))
                .foregroundStyle(Color(R.Color.gray200))

            VStack(alignment: .leading, spacing: 3) {
                Text("{100}만원")
                    .font(Font(R.Font.h2))
                    .foregroundStyle(Color(R.Color.white))
                Rectangle()
                    .fill(Color(R.Color.orange500))
                    .frame(width: .infinity, height: 2)
            }
            .padding(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
            .background(Color(R.Color.gray800))
            .cornerRadius(4.0)
            .padding(.bottom, 30)

            Text(subTitle)
                .font(Font(R.Font.body1))
                .foregroundStyle(Color(R.Color.gray400))
                .padding(.bottom, 8)

            HStack {
                Text("일일 적정 지출 금액 ")
                    .foregroundColor(Color(R.Color.white))
                +
                Text("{3}만원 ")
                    .foregroundColor(Color(R.Color.orange500))
                +
                Text("이하")
                    .foregroundColor(Color(R.Color.white))
                Spacer()
            }
            .modifier(BudgetSettingSubTitleModifier())
        }
    }
}

#Preview {
    BudgetDetail04View(budgetSettingViewModel: BudgetSettingViewModel())
}
