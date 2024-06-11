//
//  PriceTextFieldView.swift
//  MMM
//
//  Created by yuraMacBookPro on 2/21/24.
//

import UIKit
import Then
import SnapKit
import SwiftUI
import Combine

final class PriceTextFieldView: BaseView {
    // MARK: - UI Components
    private lazy var priceTextField = UITextField()
    private lazy var warningLabel = UILabel()
    private let viewModel: BudgetSettingViewModel
    private lazy var cancellable: Set<AnyCancellable> = .init()
    
    init(viewModel: BudgetSettingViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Underline 호출
        priceTextField.setUnderLine(color: R.Color.orange500)
    }
}

extension PriceTextFieldView {
    override func setAttribute() {
        priceTextField = priceTextField.then {
//            if let price = Int(viewModel.budgetAmt) {
//                $0.text = price.withCommas() + "만원"
//            }
            
            let isStep2 = viewModel.currentStep == .income
            
            if viewModel.budgetAmt != 0 {
                $0.text = isStep2 ? viewModel.budgetAmt.withCommas() : ""
            }
            
            let placeholder = "만원 단위로 입력"

            
            $0.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: R.Color.gray500])
            $0.font = R.Font.h2
            $0.textColor = isStep2 ? R.Color.white : R.Color.gray900
            $0.keyboardType = .numberPad     // 숫자 키보드
            $0.tintColor = R.Color.gray400     // cursor color
            $0.setNumberMode(unit: isStep2 ? "만원" : " 만원")     // 단위 설정
            $0.setClearButton(with: R.Icon.cancel, mode: .always) // clear 버튼
        }
        
        warningLabel = warningLabel.then {
            $0.text = "최대 작성 단위을 넘어선 금액이에요. (최대 1억)"
            $0.font = R.Font.body3
            $0.textColor = R.Color.red500
            $0.textAlignment = .left
            $0.isHidden = true
        }

    }
    
    override func setHierarchy() {
        addSubviews(priceTextField, warningLabel)
    }
    
    override func setLayout() {
        priceTextField.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
        }
        
        warningLabel.snp.makeConstraints {
            $0.top.equalTo(priceTextField.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
        }
    }
    
    override func setBind() {
        // 현재 스탭에 따라서 binding을 다르게 해줌
        if viewModel.currentStep == .income {
            priceTextField.textPublisher
                .map{String(Array($0).filter{$0.isNumber})} // 숫자만 추출
                .map { Int($0) ?? 0 }
                .assignOnMainThread(to: \.budgetAmt, on: viewModel)
                .store(in: &cancellable)
        } else if viewModel.currentStep == .expense {
            priceTextField.textPublisher
                .map{String(Array($0).filter{$0.isNumber})} // 숫자만 추출
                .map { Int($0) ?? 0 }
                .assignOnMainThread(to: \.estimatedEarningAmtForTextField, on: viewModel)
                .store(in: &cancellable)
        }
    }
}

struct PriceTextFieldViewRepresentable: UIViewRepresentable {
    typealias UIViewType = PriceTextFieldView
    var viewModel: BudgetSettingViewModel
    
    func makeUIView(context: Context) -> PriceTextFieldView {
        let view = PriceTextFieldView(viewModel: viewModel)
        return view
    }
    
    func updateUIView(_ uiView: PriceTextFieldView, context: Context) {
        
    }
}
