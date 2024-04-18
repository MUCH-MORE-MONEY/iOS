//
//  BudgetSettingViewModel.swift
//  MMM
//
//  Created by yuraMacBookPro on 2/20/24.
//

import SwiftUI
import Combine

final class BudgetSettingViewModel: ObservableObject {
    @Published var budget: Int = 0
    @Published var priceInput: String = ""
    @Published var isFocusTextField: Bool = false
    @Published var isSliderView: Bool = true
    @Published var isFirstStep: Bool = true
    
    @Published var isCalenderCheckboxEnable: Bool = false
    
    @Published var compeleteSteps: Bool = false
    @Published var transition: Bool = true  // true이면 next
    
    
    // MARK: - Public properties
    // 들어온 퍼블리셔의 값 일치 여부를 반환하는 퍼블리셔
    lazy var isPriceVaild: AnyPublisher<Bool, Never> = $priceInput
        .map {0 <= Int($0) ?? 0 && Int($0) ?? 0 <= 10_000 } // 1억(1,000만원)보다 작을 경우
        .eraseToAnyPublisher()
    
    lazy var isValidByWon: AnyPublisher<Bool, Never> = $priceInput
        .map { 0 <= Int($0) ?? 0 && Int($0) ?? 0 <= 100_000_000 } // 1억(1,000만원)보다 작을 경우
        .eraseToAnyPublisher()
    
    func dismissKeyboard() {
        isFocusTextField.toggle()
    }
}
