//
//  bottomPageControlView2.swift
//  MMM
//
//  Created by yuraMacBookPro on 12/21/23.
//

import UIKit
import SnapKit
import Then
import ReactorKit

final class BottomPageControlView2: BaseView, View {
    typealias Reactor = BottomPageControlReactor
    
    private lazy var previousButton = UIButton()
    private lazy var nextButton = UIButton()
    private lazy var indexLabel = UILabel()
    private lazy var stackView = UIStackView()
    
    var totalItem = 0
    
    var index: Int = 0 {
        didSet {
            previousButton.isEnabled = index == 0 ? false : true
            nextButton.isEnabled = index == totalItem ? false : true
        }
    }
    
    func bind(reactor: BottomPageControlReactor) {
        bindAction(reactor)
        bindState(reactor)
    }
}

// MARK: - Bind
extension BottomPageControlView2 {
    private func bindAction(_ reactor: BottomPageControlReactor) {
        
    }
    
    private func bindState(_ reactor: BottomPageControlReactor) {
        
    }
}

// MARK: - Action
extension BottomPageControlView2 {
    func didTapPreviousButton() {

    }
    
    func didTapNextButton() {

    }
    
    func updateView() {

    }
    
    func setViewModel(_ viewModel: HomeDetailViewModel, _ economicActivityId: [String]) {

    }
}


//MARK: - Attribute & Hierarchy & Layouts
extension BottomPageControlView2 {
    override func setAttribute() {
        super.setAttribute()
    }
    
    override func setHierarchy() {
        super.setHierarchy()
    }
    
    override func setLayout() {
        super.setLayout()
        
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.left.right.bottom.equalToSuperview()
        }
        
        indexLabel.snp.makeConstraints {
            $0.centerY.equalTo(nextButton.snp.centerY)
        }
    }
}
