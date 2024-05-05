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
    @Published var expectedIncome: String = ""
    @Published var previousIncome: Int = 10000000
    @Published var savingPrice: Int = 0
    @Published var isFocusTextField: Bool = false
    @Published var isShowingTextFieldSheet: Bool = false     //03 Setting뷰의 직접 입력하기 시트
    @Published var isFirstStep: Bool = true
    
    @Published var isCalenderCheckboxEnable: Bool = false
    
    @Published var compeleteSteps: Bool = false
    @Published var transition: Bool = true  // true이면 next
    
    @Published var currentStep: CurrentStep = .main
    
    private var cancellables = Set<AnyCancellable>()

    
    enum CurrentStep {
        case main       // 예산 세팅
        case income     // 예상 수입 설정
        case expense    // 지출 예산 설정
        case budget     // 사용가능 예산
        case calendar   // 날짜
    }
    
    // MARK: - Public properties
    // 들어온 퍼블리셔의 값 일치 여부를 반환하는 퍼블리셔
    lazy var isPriceVaild: AnyPublisher<Bool, Never> = $expectedIncome
        .map {0 <= Int($0) ?? 0 && Int($0) ?? 0 <= 10_000 } // 1억(1,000만원)보다 작을 경우
        .eraseToAnyPublisher()
    
    lazy var isValidByWon: AnyPublisher<Bool, Never> = $expectedIncome
        .map { 0 <= Int($0) ?? 0 && Int($0) ?? 0 <= 100_000_000 } // 1억(1,000만원)보다 작을 경우
        .eraseToAnyPublisher()
    
    // step2에서 예상수익을 입력하지 않았을 떄를 판단하는 변수
    @Published var isNextButtonDisable: Bool = false
    
    
    init() {
        bind()
    }
    
    private func bind() {
        // 두 변수를 합친 값을 계산하고 새로운 속성으로 사용
        Publishers.CombineLatest($expectedIncome, $currentStep)
            .map { expectedIncome, currentStep in
                // 예상 수입이 비어있지 않고, 현재 단계가 income이 아니면 버튼을 활성화
                return expectedIncome.isEmpty && currentStep == .income
            }
            .sink(receiveValue: { [weak self] isActive in
                guard let self = self else { return }
                self.isNextButtonDisable = isActive
            })
            .store(in: &cancellables)
    }
    
    
    func dismissKeyboard() {
        isFocusTextField.toggle()
    }
}
