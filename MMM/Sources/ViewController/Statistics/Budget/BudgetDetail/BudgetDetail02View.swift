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
        VStack {
            Text(subTitle)
                .font(Font(R.Font.regular20))
                .foregroundStyle(Color(R.Color.gray200))

            PriceTextFieldViewRepresentable(viewModel: budgetSettingViewModel)
        }
        .background(Color(R.Color.gray900))
    }
}

#Preview {
    BudgetDetail02View(budgetSettingViewModel: BudgetSettingViewModel())
}

