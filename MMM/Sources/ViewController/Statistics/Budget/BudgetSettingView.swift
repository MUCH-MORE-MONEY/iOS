//
//  BudgetSettingView.swift
//  MMM
//
//  Created by yuraMacBookPro on 2/20/24.
//

import SwiftUI

struct BudgetSettingView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel: BudgetSettingViewModel
    @FocusState private var isFocus: Bool
    @Environment(\.dismiss) private var dismiss
    
    private var nextButtonTitle: String {
        viewModel.currentStep == .complete ? "완료" : "다음"
    }
    
    private var startTransition: Edge {
        return viewModel.transition ? .leading : .trailing
    }
    
    private var toTransition: Edge {
        return viewModel.transition ? .trailing : .leading
    }
    
    
    
    var body: some View {
        NavigationView {
            VStack {
                SegmentedView(selected:$viewModel.currentStep)
                    .padding(.top, 16)
                    .padding([.leading, .trailing], 24)
                VStack {
                    switch viewModel.currentStep {
                    case .main:
                        BudgetDetail01View(budgetSettingViewModel: viewModel)
                            .navigationTransition(start: startTransition, to: toTransition)
                    case .income:
                        BudgetDetail02View(viewModel: viewModel)
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
                    case .calendar, .complete:
                        BudgetDetail05View(viewModel: viewModel)
                            .navigationTransition(start: startTransition, to: toTransition)
                    }
                }
                .padding(.top, 48)
                .padding([.leading, .trailing], 24)
                .animation(.easeInOut, value: viewModel.currentStep)
                
                Spacer()
                HStack(spacing: 8) {
                    if !viewModel.isFirstStep {
                        // 이전 버튼
                        Button {
                            viewModel.transition = true
                            
                            switch viewModel.currentStep {
                            case .main:
                                break
                            case .income:
                                viewModel.isFirstStep = true
                                viewModel.currentStep = .main
                            case .expense:
                                viewModel.currentStep = .income
                            case .budget:
                                viewModel.currentStep = .expense
                            case .calendar:
                                viewModel.currentStep = .budget
                            case .complete:
                                viewModel.currentStep = .calendar
                            }
                        } label: {
                            Text("이전")
                                .frame(maxWidth: .infinity, minHeight: 56)
                                .font(R.Font.title1.suFont)
                                .foregroundStyle(R.Color.gray100.suColor)
                                .background(R.Color.gray800.suColor)
                        }
                    }
                    
                    // 다음 버튼
                    Button {
                        viewModel.transition = false
                        
                        switch viewModel.currentStep {
                        case .main:
                            viewModel.isFirstStep = false
                            viewModel.currentStep = .income
                        case .income:
                            viewModel.currentStep = .expense
                        case .expense:
                            viewModel.currentStep = .budget
                        case .budget:
                            viewModel.currentStep = .calendar
                        case .calendar:
                            viewModel.currentStep = .complete
                        case .complete:
                            viewModel.upsertEconomicPlan()
                        }
                    } label: {
                        Text(nextButtonTitle)
                            .frame(maxWidth: .infinity, minHeight: 56)
                            .font(R.Font.title1.suFont)
                            .foregroundStyle(viewModel.isNextButtonDisable ? R.Color.gray400.suColor : R.Color.gray100.suColor)
                            .background(viewModel.isNextButtonDisable ? R.Color.gray600.suColor: (viewModel.isFirstStep ? R.Color.gray800.suColor : R.Color.orange500.suColor))

                    }
                    // step2에서 값을 입력하지 않았을 경우 disable
                    .disabled(viewModel.isNextButtonDisable)
                }
                .padding([.leading, .trailing, .bottom], 24)
            }
            .navigationBarBackButtonHidden()
            .background(Color(R.Color.gray900))
            .onTapGesture {
                viewModel.dismissKeyboard()
            }
            .navigationTitle("지출 예산 설정하기")
            .navigationBarTitleDisplayMode(.inline)
            .foregroundStyle(R.Color.white.suColor)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("닫기")
                            .foregroundStyle(R.Color.white.suColor)
                            .font(R.Font.body1.suFont)
                    }
                }
            }
        }
    }
}

#Preview {
    BudgetSettingView(viewModel: BudgetSettingViewModel(budget: Budget.getDummy()))
}

struct SegmentedView: View {
    
    let segments: [BudgetSettingViewModel.CurrentStep] = [.main, .income, .expense, .budget, .calendar]
    @Binding var selected: BudgetSettingViewModel.CurrentStep
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
                            // 5번 페이지에서는 두개의 화면을 쓰기 때문에 .complete == .calendar를 동일 취급해줘야함
                            if selected == segment || (selected == .complete && segment == .calendar) {
                                Capsule()
                                    .fill(Color(R.Color.white))
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
    func budgetSettingViewUI(_ budget: Budget) -> UIViewController {
        let viewModel = BudgetSettingViewModel(budget: budget)
        let vc = BudgetSettingHostingController(rootView: BudgetSettingView(viewModel: viewModel))
        return vc
    }
}
