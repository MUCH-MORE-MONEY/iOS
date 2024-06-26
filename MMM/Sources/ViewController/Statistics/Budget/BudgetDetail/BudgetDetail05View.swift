//
//  BudgetDetail05View.swift
//  MMM
//
//  Created by yuraMacBookPro on 2/23/24.
//

import SwiftUI
import Combine

struct BudgetDetail05View: View {
    @ObservedObject var budgetSettingViewModel: BudgetSettingViewModel
    
    let title = "일별 환산된 적정 지출 금액을\n달력에서 확인하시겠어요?"
    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .font(Font(R.Font.regular20))
                    .foregroundStyle(Color(R.Color.gray200))

                Spacer()
            }
            .padding(.bottom, 14)
            
            HStack {
                Text("일일 적정 지출 금액 ")
                    .foregroundColor(Color(R.Color.white))
                +
                Text("{3}만원 ")
                    .foregroundColor(Color(R.Color.orange500))
                
                Spacer()
            }
            .modifier(BudgetSettingSubTitleModifier())
            .padding(.bottom, 14)
            
            Image(uiImage: R.Icon.imageCalenderUsecase144)

                .frame(width: .infinity)
            
            VStack(alignment: .leading) {
                HStack {
                    CalendarLabel(price: 3, color: R.Color.orange400)
                    CalendarLabel(price: 3, color: R.Color.orange200)
                }
                .padding(.bottom, 51)
                
                Button {
                    debugPrint("checkbox tapped")
                } label: {
                    /*@START_MENU_TOKEN@*/Text("Button")/*@END_MENU_TOKEN@*/
                }
            }
        }
    }
    
}

#Preview {
    BudgetDetail05View(budgetSettingViewModel: BudgetSettingViewModel())
}


struct CalendarLabel: View {
    var price: Int
    var color: UIColor
    var body: some View {
        VStack {
            HStack(spacing: 4) {
                Text("{\(price)}만원 이상 지출")
                
                Circle()
                    .fill(Color(color))
                    .frame(width: 16, height: 16)
            }
        }
    }
}
