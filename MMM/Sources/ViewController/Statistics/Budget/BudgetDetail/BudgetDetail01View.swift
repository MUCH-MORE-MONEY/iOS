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
                TextWithColoredSubstring()
                Spacer()
            }
            
            
            Image(uiImage: R.Icon.iconBudgetSettingCalendar)
                .padding(.top, 89)
            
            Spacer()
        }
    }
}

struct TextWithColoredSubstring: View {
    
    var body: some View {
        let basicText1 = "내가 고정적으로 쓰는 돈을 고려하여\n"
        let textbold1 = "이번 달의 수입"
        let basicText2 = "과 "
        let textbold2 = "저축할 금액"
        let basicText3 = "을 적고\n 매일 "
        let textBoldWithColor = "얼마 지출할 수 있는지"
        let basicText4 = " 알아보세요!"
        
        let basicFont = R.Font.regular20
        let boldFont = R.Font.h5
        let basicTextColor = R.Color.white
        let coloredTextColor = R.Color.yellow300
        
        
        
        
        // 설정할 기본 폰트 및 색상
        
        
        // 기본 속성
        let attributes: [NSAttributedString.Key: Any] = [
            .font: basicFont,
            .foregroundColor: basicTextColor
        ]
        // bold
        let attributes2: [NSAttributedString.Key: Any] = [
            .font: boldFont,
            .foregroundColor: basicTextColor
        ]
        // bold & yellow
        let attributes3: [NSAttributedString.Key: Any] = [
            .font: boldFont,
            .foregroundColor: coloredTextColor
        ]
        // 내가 고정적으로 쓰는 돈을 고려하여
        let attributedString = NSMutableAttributedString(string: basicText1)
        attributedString.addAttributes(attributes, range: NSRange(location: 0, length: basicText1.count))
        
        //이번 달의 수입
        let text2 = NSAttributedString(string: textbold1, attributes: attributes2)
        attributedString.append(text2)
        // 과
        let text3 = NSAttributedString(string: basicText2, attributes: attributes)
        attributedString.append(text3)
        // 저축할 금액
        let text4 = NSAttributedString(string: textbold2, attributes: attributes2)
        attributedString.append(text4)
        // 을 적고\n 매일
        let text5 = NSAttributedString(string: basicText3, attributes: attributes)
        attributedString.append(text5)
        // 얼마 지출할 수 있는지
        let text6 = NSAttributedString(string: textBoldWithColor, attributes: attributes3)
        attributedString.append(text6)
        // 알아보세요!
        let text7 = NSAttributedString(string: basicText4, attributes: attributes)
        attributedString.append(text7)
        
        let resultString = AttributedString(attributedString)
        
        return Text(resultString)
            .lineSpacing(15) // 행간 설정
    }
}

#Preview {
    BudgetDetail01View(budgetSettingViewModel: BudgetSettingViewModel(budget: Budget.getDummy(), dateYM: "202404"))
}
