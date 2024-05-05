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
                Text("지난 달 작성한 수입")
                Text("\(viewModel.previousIncome.withCommas())원")
            }
            .font(Font(R.Font.body3))
            .foregroundStyle(Color(R.Color.gray300))

            Spacer()
        }
    }
}

#Preview {
    BudgetDetail02View(viewModel: BudgetSettingViewModel())
}

