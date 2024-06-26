//
//  BudgetDetail03View.swift
//  MMM
//
//  Created by yuraMacBookPro on 2/23/24.
//

import SwiftUI
import Combine

struct BudgetDetail03View: View {
    @ObservedObject var viewModel: BudgetSettingViewModel
    @FocusState var isFocus: Bool
    @State private var cancellables = Set<AnyCancellable>()
    
    private var silderWidth: CGFloat {
        UIScreen.width - 88 // 전체 길이 - Padding * 20
    }
    
    private var toolTipText: String {
        get {
//            return viewModel.estimatedEarningAmt / viewModel.budgetAmt
            return "\(Int(viewModel.estimatedpercentage))"
        }
    }
    
    let contentArr = ["전문가들이 추천하는 저축률이에요.\n시드머니가 필요한 사회초년생에게 적합해요.",
                   " 권장 저축률보다 목표가 낮아요.\n이번 달 큰 소비 계획이 있으신가 봐요.",
                   "가급적 이 정도는 저축하는 것을 추천해요.\n목표가 높으면 더 좋고요!",
                   "이 기세라면 돈을 빠르게 모을 수 있어요.\n꾸준히 종잣돈을 모아봐요.",
                   "경제적 자립에 한 발짝 다가갈 수 있어요.\n절약을 응원할게요!"]
    
    private var contentText: String {
        switch viewModel.estimatedpercentage {
        case 0..<25:
            return contentArr[0]
        case 25..<50:
            return contentArr[1]
        case 50..<75:
            return contentArr[2]
        default:
            return contentArr[3]
        }
    }
    
    @State private var showingSheet: Bool = false
    
    private var isTextFieldSheetConfrimButtonOn: Bool {
        viewModel.estimatedEarningAmtForTextField != 0
    }
    
    private var estimatedEarningLabel: String {
//        let amount = Double(viewModel.budgetAmt) * Double(viewModel.estimatedpercentage) / 100
//        viewModel.estimatedEarningAmt = amount
        let amount = viewModel.estimatedEarning
        return "\(Int(amount))"
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("수입의 얼마를 모으실 건가요?")
                    .font(Font(R.Font.regular20))
                    .foregroundStyle(Color(R.Color.gray200))
                Spacer()
            }
            
            VStack {
                Text("\(estimatedEarningLabel)만원")
                    .font(Font(R.Font.h2))
                    .foregroundStyle(Color(R.Color.white))
                    .padding(.bottom, 22)
                
                Text(contentText)
                    .multilineTextAlignment(.center)
                    .font(Font(R.Font.medium14))
                    .foregroundStyle(Color(R.Color.orange100))
                    .padding(.bottom, 32)
                
                Button {
                    showingSheet = true
                } label: {
                    Text("직접 입력하기")
                        .underline()
                        .font(Font(R.Font.body3))
                        .foregroundStyle(Color(R.Color.gray500))
                }
                Spacer()
            
                // 슬라이더 값에 따라 툴팁 위치 동적 조정
                TooltipView(text: "\(toolTipText)%", color: R.Color.orange500.suColor)
                    .offset(x: -(silderWidth / 2) + (silderWidth / 100) * viewModel.estimatedpercentage, y: -30) // 가정: 슬라이더 너비가 300pt
                
                BudgetSlider(value: $viewModel.estimatedpercentage, range: 0...100)
                    .padding([.leading, .trailing], 20)
            }
            .padding(.top, 136)
        }
        .sheet(isPresented: $showingSheet, content: {
            VStack(spacing: 24) {
                HStack {
                    Text("이번 달 저축 금액")
                        .font(R.Font.h5.suFont)
                        .foregroundStyle(R.Color.black.suColor)
                    
                    Spacer()
                    
                    Button {
//                        viewModel.estimatedpercentage = 100.0 / Double(viewModel.budgetAmt / viewModel.estimatedEarningAmtForTextField)
        
                        viewModel.estimatedpercentage = Double(viewModel.estimatedEarningAmtForTextField) / Double(viewModel.budgetAmt) * 100.0
                        
                        showingSheet.toggle()
                    } label: {
                        Text("확인")
                            .font(R.Font.title3.suFont)
                            .foregroundStyle(viewModel.isEstimatedEarningAmtValid ? R.Color.black.suColor : R.Color.gray500.suColor)
                    }
                    .disabled(!viewModel.isEstimatedEarningAmtValid)
                }
                .padding(.top, 32)
                
                VStack(alignment: .leading, spacing: 12) {
                    PriceTextFieldViewRepresentable(viewModel: viewModel)
                        .padding(.top, 16)
                        .focused($isFocus)
                        .frame(height: 40)
                        .onAppear {
                            viewModel.$isFocusTextField
                                .sinkOnMainThread { isFocus in
                                    self.isFocus = false
                                }
                                .store(in: &cancellables)
                        }
                    if !viewModel.isEstimatedEarningAmtValid && viewModel.estimatedEarningAmtForTextField != 0 {
                        Text("예상 수입을 넘어선 금액이에요 (최대 \(viewModel.budgetAmt)만원)")
                            .font(R.Font.body3.suFont)
                            .foregroundStyle(R.Color.red500.suColor)
                    }
                }
                Spacer()
            }
            .padding([.leading, .trailing], 24)
            .presentationDetents([.height(174)])
        })
    }
}

#Preview {
    BudgetDetail03View(viewModel: BudgetSettingViewModel(budget: Budget.getDummy(), dateYM: "202404"))
}
