//
//  BudgetSettingView.swift
//  MMM
//
//  Created by yuraMacBookPro on 2/20/24.
//

import SwiftUI

struct BudgetSettingView: View {
    @State var currentStep: CurrentStep = .main
    @StateObject var budgetSettingViewModel = BudgetSettingViewModel()
    @FocusState private var isFocus: Bool
    
    enum CurrentStep {
        case main       // 예산 세팅
        case income     // 예상 수입 설정
        case expense    // 지출 예산 설정
        case budget     // 사용가능 예산
        case calendar   // 날짜
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
                        BudgetDetail01View(budgetSettingViewModel: budgetSettingViewModel)
                            .navigationTransition()
                    case .income:
                        BudgetDetail02View(budgetSettingViewModel: budgetSettingViewModel)
                            .onTapGesture {
                                // 강제로 탭 제스처를 만들어서 전체 뷰에 대한 터치 이벤트를 막음
                            }
                            .navigationTransition()
                    case .expense:
                        BudgetDetail03View(budgetSettingViewModel: budgetSettingViewModel)
                            .onTapGesture {
                                // 강제로 탭 제스처를 만들어서 전체 뷰에 대한 터치 이벤트를 막음
                            }
                            .navigationTransition()
                    case .budget:
                        BudgetDetail04View(budgetSettingViewModel: budgetSettingViewModel)
                            .navigationTransition()
                    case .calendar:
                        BudgetDetail05View(viewModel: budgetSettingViewModel)
                            .navigationTransition()
                    }
                }
                .padding(.top, 48)
                .padding([.leading, .trailing], 24)
                .animation(.easeInOut, value: currentStep)
                
                Spacer()
                
                Button {
                    switch currentStep {
                    case .main:
                        currentStep = .income
                    case .income:
                        currentStep = .expense
                    case .expense:
                        currentStep = .budget
                    case .budget:
                        currentStep = .calendar
                    case .calendar:
                        currentStep = .main
                    }
                } label: {
                    Text("다음")
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: 56)
                    
                        .font(Font(R.Font.title1))
                        .foregroundStyle(Color(R.Color.gray100))
                        .background(Color(R.Color.gray800))
                }
                .padding([.leading, .trailing, .bottom], 24)
            }
            .background(Color(R.Color.gray900))
            .onTapGesture {
                budgetSettingViewModel.dismissKeyboard()
            }
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
