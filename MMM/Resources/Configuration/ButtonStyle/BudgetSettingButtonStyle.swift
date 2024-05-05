//
//  BudgetSettingButtonStyle.swift
//  MMM
//
//  Created by Park Jungwoo on 5/5/24.
//

import SwiftUI

struct BudgetSettingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(configuration.isPressed ? R.Color.orange500.suColor : R.Color.gray600.suColor) // 버튼이 클릭되었을 때 배경색 변경
            .foregroundColor(configuration.isPressed ? R.Color.white.suColor : R.Color.gray400.suColor) // 버튼 텍스트 색상 설정
    }
}
