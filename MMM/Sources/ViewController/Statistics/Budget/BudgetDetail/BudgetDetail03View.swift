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
    @State private var price = 100.0
    @FocusState var isFocus: Bool
    @State private var cancellables = Set<AnyCancellable>()
    
    private var priceText: String {
        get {
            return "\(Int(price))"
        }
    }
    
    let contentArr = ["전문가들이 추천하는 저축률이에요.\n시드머니가 필요한 사회초년생에게 적합해요.",
                   " 권장 저축률보다 목표가 낮아요.\n이번 달 큰 소비 계획이 있으신가 봐요.",
                   "가급적 이 정도는 저축하는 것을 추천해요.\n목표가 높으면 더 좋고요!",
                   "이 기세라면 돈을 빠르게 모을 수 있어요.\n꾸준히 종잣돈을 모아봐요.",
                   "경제적 자립에 한 발짝 다가갈 수 있어요.\n절약을 응원할게요!"]
    
    private var contentText: String {
        switch price {
        case 0...100:
            return contentArr[0]
        default:
            return "니 맘대로 해라"
        }
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
                Text("\(viewModel.expectedIncome)만원")
                    .font(Font(R.Font.h2))
                    .foregroundStyle(Color(R.Color.white))
                    .padding(.bottom, 22)
                
                Text(contentText)
                    .multilineTextAlignment(.center)
                    .font(Font(R.Font.medium14))
                    .foregroundStyle(Color(R.Color.orange100))
                    .padding(.bottom, 32)
                
                Button {
                    viewModel.isShowingTextFieldSheet = true
                } label: {
                    Text("직접 입력하기")
                        .underline()
                        .font(Font(R.Font.body3))
                        .foregroundStyle(Color(R.Color.gray500))
                }
                Spacer()
            
                // 슬라이더 값에 따라 툴팁 위치 동적 조정
                TooltipView(text: "\(priceText)%", color: R.Color.orange500.suColor)
                    .offset(x: 0, y: -30) // 툴팁 위치 조정
                    .offset(x: CGFloat((price - 100)), y: 0) // 가정: 슬라이더 너비가 300pt

                BudgetSlider(value: $price, range: 0...200)
            }
            .padding(.top, 136)
        }
        .sheet(isPresented: $viewModel.isShowingTextFieldSheet, content: {
            VStack(spacing: 24) {
                HStack {
                    Text("이번 달 저축 금액")
                        .font(R.Font.h5.suFont)
                        .foregroundStyle(R.Color.black.suColor)
                    
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        Text("확인")
                            .font(R.Font.title3.suFont)
                            .foregroundStyle(R.Color.gray500.suColor)
                    }
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
                    if !viewModel.isSavingValid {
                        Text("예상 수입을 넘어선 금액이에요 (최대 {예상수입}만원)")
                            .font(R.Font.body3.suFont)
                            .foregroundStyle(R.Color.red500.suColor)
                            .autoShake(shakeCount: $viewModel.shakes, triggerFlag: viewModel.isSavingValid)
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
    BudgetDetail03View(viewModel: BudgetSettingViewModel(budget: Budget.getDummy()))
}
