//
//  BudgetSettingViewModel.swift
//  MMM
//
//  Created by yuraMacBookPro on 2/20/24.
//

import SwiftUI
import Combine

final class BudgetSettingViewModel: ObservableObject {
    // 이전 달 예산 금액
    @Published var budget: Budget
    // budget02에서 사용하는 price property
    @Published var budgetAmt: Int = 0
    // budget03에서 사용하는 price property
    @Published var estimatedEarningAmt: Int = 0
    
    @Published var isFocusTextField: Bool = false
    //03 Setting뷰의 직접 입력하기 시트
    @Published var isShowingTextFieldSheet: Bool = false
    // step1일 경우 버튼의 사이즈가 다르기 때문에 사용
    @Published var isFirstStep: Bool = true
    
    @Published var isCalenderCheckboxEnable: Bool = false

    @Published var transition: Bool = true  // true이면 next
    // 현재 segment의 step
    @Published var currentStep: CurrentStep = .main
    // 들어온 퍼블리셔의 값 일치 여부를 반환하는 퍼블리셔 -> budget02에서 textfield가 1억 넘었을 경우를 나타냄
    @Published var isBudgetAmtValid: Bool = true
    // 수입보다 저축 금액이 큰지 판단하여 warning label을 띄워주는 변수 -> budget03
    @Published var isEstimatedEarningAmtValid: Bool = true
    // shake 에니메이션 상수
    @Published var shakes: CGFloat = 0
    
    @Published var isLoading = true
    
    private var cancellables = Set<AnyCancellable>()

    @Published var response: UpsertEconomicPlanResDto?
    
    enum CurrentStep {
        case main       // 01 : 예산 세팅
        case income     // 02 : 예상 수입 설정
        case expense    // 03 : 지출 예산 설정
        case budget     // 04 : 사용가능 예산
        case calendar   // 05 : 날짜
        case complete   // 05 : 완료
    }
    
    // MARK: - Public properties
    // 들어온 퍼블리셔의 값 일치 여부를 반환하는 퍼블리셔
    
    lazy var isValidByWon: AnyPublisher<Bool, Never> = $budgetAmt
        .map { 0 <= Int($0) ?? 0 && Int($0) ?? 0 <= 100_000_000 } // 1억(1,000만원)보다 작을 경우
        .eraseToAnyPublisher()
    
    // step2에서 예상수익을 입력하지 않았을 떄를 판단하는 변수
    @Published var isNextButtonDisable: Bool = false
    
    
    init(budget: Budget) {
        self.budget = budget
        bind()
    }
    
    private func bind() {
        // 세 변수를 합친 값을 계산하고 새로운 속성으로 사용
        Publishers.CombineLatest($currentStep, $isBudgetAmtValid)
            .map { currentStep , isBudgetAmtValid in
                // 예상 수입이 비어있지 않고, 현재 단계가 income이 아니면 버튼을 활성화 OR 예산을 정확히 입력하지 않았을 경우
                return currentStep == .income && !isBudgetAmtValid
            }
            .sink(receiveValue: { [weak self] isActive in
                guard let self = self else { return }
                self.isNextButtonDisable = isActive
            })
            .store(in: &cancellables)
        
        $budgetAmt
            .map { amt in
                return 0 < amt && amt <= 10_000
            }
            .assign(to: &$isBudgetAmtValid)
        
        $estimatedEarningAmt
            .map { amt in
                return 0 < amt && amt <= 10_000
            }
            .assign(to: &$isEstimatedEarningAmtValid)
    }
    
    
    func dismissKeyboard() {
        isFocusTextField.toggle()
    }
    
    func upsertEconomicPlan() {
        guard let token = Constants.getKeychainValue(forKey: Constants.KeychainKey.token) else { return }
        self.isLoading = true
        
        APIClient.dispatch(
            APIRouter.upsertEconomicPlanReqDto(
                headers: APIHeader.Default(token: token),
                body:APIParameters.UpsertEconomicPlanReqDto(
                    budgetAmt: budgetAmt * 10000,
                    economicPlanYM: "202404",
                    estimatedEarningAmt: estimatedEarningAmt * 10000)))
        .sink { data in
            switch data {
            case .failure(_):
                // 실패했을 경우 alert 같은 걸 띄워줘야함
                debugPrint("upsert fail")
                break
            case .finished:
                break
            }
            self.isLoading = false
        } receiveValue: { response in
            print(response)
            self.response = response
            
            // UIWindowScene을 통해 현재 활성화된 씬을 찾고, 그 씬의 windows 배열에서 visible인 윈도우를 찾습니다.
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
                // UINavigationController를 찾아 pop합니다.
                let navigationController = self.findNavigationController(viewController: rootViewController)
                navigationController?.popViewController(animated: true)
            }
        }
        .store(in: &cancellables)
    }
    
    // UIViewController에서 UINavigationController을 찾는 재귀 함수
    func findNavigationController(viewController: UIViewController) -> UINavigationController? {
        if let navigationController = viewController as? UINavigationController {
            return navigationController
        } else if let presentedViewController = viewController.presentedViewController {
            return findNavigationController(viewController: presentedViewController)
        } else {
            return nil
        }
    }
}
