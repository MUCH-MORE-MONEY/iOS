//
//  BudgetDetail02View.swift
//  MMM
//
//  Created by yuraMacBookPro on 2/21/24.
//

import SwiftUI
import Combine

struct BudgetDetail02View: View {
    @ObservedObject var viewModel: BudgetSettingViewModel
    @FocusState private var isFocus: Bool
    @State private var cancellables = Set<AnyCancellable>()
    
    private let subTitle = "이번 달 예상 수입은 얼마인가요?"
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(subTitle)
                .font(Font(R.Font.regular20))
                .foregroundStyle(Color(R.Color.gray200))
                .padding(.bottom, 16)

            PriceTextFieldViewRepresentable(viewModel: viewModel)
                .focused($isFocus)
                .frame(height: 40)
                .onAppear {
                    viewModel.$isFocusTextField
                        .sinkOnMainThread { isFocus in
                            self.isFocus = false
                        }
                        .store(in: &cancellables)
                }
            
            HStack(spacing: 4) {
                Spacer()
                
                if viewModel.isBudgetAmtValid {
                    Group {
                        if let budget = viewModel.budget.budget {
                            Text("지난 달 작성한 수입")
                            Text("\(budget.withCommas())원")
                        }
                    }
                    .foregroundStyle(R.Color.gray300.suColor)
                    
                } else {
                    Text("최대 작성 단위을 넘어선 금액이에요. (최대 1억)")
                        .foregroundStyle(R.Color.red500.suColor)
                }
            }
            .font(Font(R.Font.body3))
            .autoShake(shakeCount: $viewModel.shakes, triggerFlag: !viewModel.isBudgetAmtValid)
            Spacer()
        }
    }
}

#Preview {
    BudgetDetail02View(viewModel: BudgetSettingViewModel(budget: Budget.getDummy(), dateYM: "202404"))
}

