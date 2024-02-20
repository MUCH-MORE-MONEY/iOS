//
//  BudgetSettingView.swift
//  MMM
//
//  Created by yuraMacBookPro on 2/20/24.
//

import SwiftUI

struct BudgetSettingView: View {
    var body: some View {
        Text("예산 설정")
    }
}

#Preview {
    BudgetSettingView()
}

final class BudgetSettingViewInterface {
    func budgetSettingViewUI() -> UIViewController {
        let view = BudgetSettingView()
        return UIHostingController(rootView: view)
    }
}
