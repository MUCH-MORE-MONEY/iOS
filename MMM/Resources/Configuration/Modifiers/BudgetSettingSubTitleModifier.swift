//
//  BudgetSettingSubTitleModifier.swift
//  MMM
//
//  Created by yuraMacBookPro on 2/23/24.
//

import SwiftUI

struct BudgetSettingSubTitleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(Font(R.Font.title3))
            .frame(width: .infinity)
            .padding(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
            .background(Color(R.Color.gray800))
            .cornerRadius(4.0)
    }
}
