//
//  BudgetSettingView.swift
//  MMM
//
//  Created by yuraMacBookPro on 2/20/24.
//

import SwiftUI

struct BudgetSettingView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var currentStep: CurrentStep = .main
    @StateObject var viewModel = BudgetSettingViewModel()
    @FocusState private var isFocus: Bool
    
    enum CurrentStep {
        case main       // 예산 세팅
        case income     // 예상 수입 설정
        case expense    // 지출 예산 설정
        case budget     // 사용가능 예산
        case calendar   // 날짜
    }
    
    @State private var nextButtonTitle = "다음"
    
    private var startTransition: Edge {
        return !viewModel.transition ? .trailing : .leading
    }
    
    private var toTransition: Edge {
        return !viewModel.transition ? .leading : .trailing
    }
    
    var body: some View {
        NavigationView {
            VStack {
                SegmentedView(selected: $currentStep)
                    .padding(.top, 16)
                    .padding([.leading, .trailing], 24)
                VStack {
                    switch currentStep {
                    case .main:
                        BudgetDetail01View(budgetSettingViewModel: viewModel)
                            .navigationTransition(start: startTransition, to: toTransition)
                    case .income:
                        BudgetDetail02View(budgetSettingViewModel: viewModel)
                            .onTapGesture {
                                // 강제로 탭 제스처를 만들어서 전체 뷰에 대한 터치 이벤트를 막음
                            }
                            .navigationTransition(start: startTransition, to: toTransition)
                    case .expense:
                        BudgetDetail03View(viewModel: viewModel)
                            .onTapGesture {
                                // 강제로 탭 제스처를 만들어서 전체 뷰에 대한 터치 이벤트를 막음
                            }
                            .navigationTransition(start: startTransition, to: toTransition)
                    case .budget:
                        BudgetDetail04View(budgetSettingViewModel: viewModel)
                            .navigationTransition(start: startTransition, to: toTransition)
                    case .calendar:
                        BudgetDetail05View(viewModel: viewModel)
                            .navigationTransition(start: startTransition, to: toTransition)
                    }
                }
                .padding(.top, 48)
                .padding([.leading, .trailing], 24)
                .animation(.easeInOut, value: currentStep)
                
                Spacer()
                HStack(spacing: 8) {
                    if !viewModel.isFirstStep {
                        Button {
                            viewModel.transition = true
                            
                            switch currentStep {
                            case .main:
                                break
                            case .income:
                                viewModel.isFirstStep = true
                                currentStep = .main
                            case .expense:
                                currentStep = .income
                            case .budget:
                                currentStep = .expense
                            case .calendar:
                                currentStep = .budget
                            }
                        } label: {
                            Text("이전")
                                .frame(maxWidth: .infinity, minHeight: 56)
                                .font(R.Font.title1.suFont)
                                .foregroundStyle(R.Color.gray100.suColor)
                                .background(R.Color.gray800.suColor)
                        }
                    }
                    
                    Button {
                        viewModel.transition = false
                        
                        switch currentStep {
                        case .main:
                            viewModel.isFirstStep = false
                            currentStep = .income
                        case .income:
                            currentStep = .expense
                        case .expense:
                            currentStep = .budget
                        case .budget:
                            currentStep = .calendar
                        case .calendar:
                            
                            // 이미 완료 버튼으로 바뀌었고 버튼을 누르게 되면 pop
                            if nextButtonTitle == "완료" {
                                // UIWindowScene을 통해 현재 활성화된 씬을 찾고, 그 씬의 windows 배열에서 visible인 윈도우를 찾습니다.
                                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                   let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
                                    // UINavigationController를 찾아 pop합니다.
                                    let navigationController = findNavigationController(viewController: rootViewController)
                                    navigationController?.popViewController(animated: true)
                                }
                            }
                            
                            // 모든 Step 완료
                            viewModel.compeleteSteps = true
                            nextButtonTitle = "완료"
                        }
                    } label: {
                        Text(nextButtonTitle)
                            .frame(maxWidth: .infinity, minHeight: 56)
                            .font(R.Font.title1.suFont)
                            .foregroundStyle(R.Color.gray100.suColor)
                            .background(viewModel.isFirstStep ? R.Color.gray800.suColor : R.Color.orange500.suColor)

                    }

                }
                .padding([.leading, .trailing, .bottom], 24)
            }

            .background(Color(R.Color.gray900))
            .onTapGesture {
                viewModel.dismissKeyboard()
            }
        }
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

#Preview {
    BudgetSettingView()
}

struct SegmentedView: View {
    
    let segments: [BudgetSettingView.CurrentStep] = [.main, .income, .expense, .budget, .calendar]
    @Binding var selected: BudgetSettingView.CurrentStep
    @Namespace var name
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(segments, id: \.self) { segment in
                Button {
                    selected = segment
                } label: {
                    VStack {
                        ZStack {
                            Capsule()
                                .fill(Color(R.Color.gray600))
                                .frame(height: 2)
                            if selected == segment {
                                Capsule()
                                    .fill(selected == segment ? Color(R.Color.white) : Color(R.Color.gray600))
                                    .frame(height: 2)
                                    .matchedGeometryEffect(id: "Tab", in: name)
                            }
                        }
                        .padding([.leading, .trailing], 1)
                    }
                }
                .disabled(true)
            }
        }
    }
}

final class BudgetSettingHostingController: UIHostingController<BudgetSettingView> {
    override func viewDidLoad() {
        
    }
}

final class BudgetSettingViewInterface {
    func budgetSettingViewUI() -> UIViewController {
        let vc = BudgetSettingHostingController(rootView: BudgetSettingView())
        return vc
    }
}
