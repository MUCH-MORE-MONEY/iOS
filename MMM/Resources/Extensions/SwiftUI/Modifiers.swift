//
//  Modifiers.swift
//  MMM
//
//  Created by yuraMacBookPro on 5/9/24.
//

import SwiftUI

struct BudgetSettingSubTitleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(Font(R.Font.title3))
            .padding(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
            .background(Color(R.Color.gray800))
            .cornerRadius(4.0)
    }
}

struct AutoShakeModifier: ViewModifier {
    @Binding var shakeCount: CGFloat
    let triggerFlag: Bool

    func body(content: Content) -> some View {
        content
            .shake(animatableData: shakeCount)
            .onChange(of: triggerFlag) { isActive in
                if isActive {
                    UIDevice.vibrate()
                    withAnimation(.linear(duration: 0.2)) {
                        shakeCount += 1
                    }
                }
            }
    }
}
