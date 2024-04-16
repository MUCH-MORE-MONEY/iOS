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
                    case .income:
                        BudgetDetail02View(budgetSettingViewModel: budgetSettingViewModel)
                    case .expense:
                        BudgetDetail03View(budgetSettingViewModel: budgetSettingViewModel)
                    case .budget:
                        BudgetDetail04View(budgetSettingViewModel: budgetSettingViewModel)
                    case .calendar:
                        BudgetDetail05View(budgetSettingViewModel: budgetSettingViewModel)
                    }
                }
                .padding(.top, 48)
                .padding([.leading, .trailing], 24)
                
                Spacer()
                
                Button {
                    debugPrint("다음버튼 tapped")
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
