//
//  BudgetDetail02View.swift
//  MMM
//
//  Created by yuraMacBookPro on 2/21/24.
//

import SwiftUI

struct BudgetDetail02View: View {
    @ObservedObject var budgetSettingViewModel: BudgetSettingViewModel
    @State var price = ""
    
    private let subTitle = "이번 달 예상 수입은 얼마인가요?"
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(subTitle)
                .font(Font(R.Font.regular20))
                .foregroundStyle(Color(R.Color.gray200))
                .padding(.bottom, 16)

            PriceTextFieldViewRepresentable(viewModel: budgetSettingViewModel)
                .frame(height: 40)
            
            HStack(spacing: 4) {
                Spacer()
                Text("지난 달 수입")
                Text("000,000원")
            }
            .font(Font(R.Font.body3))
            .foregroundStyle(Color(R.Color.gray300))

            Spacer()
        }
    }
}

#Preview {
    BudgetDetail02View(budgetSettingViewModel: BudgetSettingViewModel())
}

