//
//  BudgetDetail05View.swift
//  MMM
//
//  Created by yuraMacBookPro on 2/23/24.
//

import SwiftUI
import Combine

struct BudgetDetail05View: View {
    @ObservedObject var viewModel: BudgetSettingViewModel
    
    private var title: String {
        if viewModel.currentStep == .complete {
            return "지출 예산이 세워졌어요!\n시작이 반이랍니다.\n이번 달도 해낼 수 있어요!"
        } else {
            return "일별 환산된 적정 지출 금액을\n달력에서 확인하시겠어요?"
        }
    }
    

    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .font(Font(R.Font.regular20))
                    .foregroundStyle(Color(R.Color.gray200))
                
                Spacer()
            }
            
            if viewModel.currentStep == .complete {
                Spacer()
                Image(uiImage: R.Icon.imageBackgroundBoost366)
            } else {
                VStack {
                    
                    
                    HStack {
                        Text("일일 적정 지출 금액 ")
                            .foregroundColor(Color(R.Color.white))
                        +
                        Text("\(viewModel.dailyRemainBudget)만원 ")
                            .foregroundColor(Color(R.Color.orange500))
                        
                        Spacer()
                    }
                    .modifier(BudgetSettingSubTitleModifier())
                    .padding([.top, .bottom], 14)
                    
                    Image(uiImage: R.Icon.imageCalenderUsecase144)
                        .resizable()
                        .scaledToFit()
                        .padding(.bottom, 23)
                    
                    VStack(alignment: .leading) {
                        HStack {
                            CalendarLabel(price: viewModel.dailyRemainBudget, color: R.Color.orange400)
                            CalendarLabel(price: viewModel.dailyRemainBudget, color: R.Color.orange200)
                            Spacer()
                        }
                        .padding(.bottom, 51)
                        
                        Button {
                            viewModel.isCalenderCheckboxEnable.toggle()
                        } label: {
                            HStack(spacing: 8) {
                                Image(uiImage: viewModel.isCalenderCheckboxEnable ? R.Icon.iconCheckboxEnableOrange : R.Icon.iconCheckboxDisable)
                                Text("달력에 표시하기")
                                    .foregroundStyle(R.Color.gray100.suColor)
                                    .font(R.Font.medium16.suFont)
                            }
                            
                        }
                    }
                }
            }
        }
        
    }
    
}

#Preview {
    BudgetDetail05View(viewModel: BudgetSettingViewModel(budget: Budget.getDummy(), dateYM: "202404"))
}


struct CalendarLabel: View {
    var price: Int
    var color: UIColor
    var body: some View {
        VStack {
            HStack(spacing: 4) {
                Text("{\(price)}만원 이상 지출")
                    .font(R.Font.medium14.suFont)
                    .foregroundStyle(R.Color.gray300.suColor)
                
                Circle()
                    .fill(Color(color))
                    .frame(width: 16, height: 16)
            }
        }
    }
}
