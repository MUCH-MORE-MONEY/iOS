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
    typealias Reactor = DetailReactor
    
    private lazy var previousButton = UIButton()
    private lazy var nextButton = UIButton()
    private lazy var indexLabel = UILabel()
    private lazy var stackView = UIStackView()
    
    var totalItem: Int = 0
    
    var index: Int = 0 {
        didSet {
            previousButton.isEnabled = index == 1 ? false : true
            nextButton.isEnabled = index == totalItem ? false : true
        }
    }
    
    func bind(reactor: DetailReactor) {
        bindAction(reactor)
        bindState(reactor)
    }
}

// MARK: - Bind
extension BottomPageControlView2 {
    private func bindAction(_ reactor: DetailReactor) {
        nextButton.rx.tap
            .map { .didTapNextButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        previousButton.rx.tap
            .map { .didTapPreviousButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(_ reactor: DetailReactor) {
        reactor.state
            .map { ($0.rowNum, $0.totalItem) }
            .distinctUntilChanged { $0.0 == $1.0 }
            .bind(onNext: updateIndexLabel)
            .disposed(by: disposeBag)

    }
}

// MARK: - Action
extension BottomPageControlView2 {
    private func updateIndexLabel(_ rowNum: Int, _ totalItem: Int) {
        self.index = rowNum
        self.totalItem = totalItem
        indexLabel.text = "\(index) / \(totalItem)"
    }
}


//MARK: - Attribute & Hierarchy & Layouts
extension BottomPageControlView2 {
    override func setAttribute() {
        super.setAttribute()
        
        previousButton = previousButton.then {
            $0.setImage(R.Icon.arrowBackBlack24, for: .normal)
            $0.setImage(R.Icon.arrowBackBlack24?.withTintColor(R.Color.gray200), for: .disabled)
        }
        
        nextButton = nextButton.then {
            $0.setImage(R.Icon.arrowNextBlack24, for: .normal)
            $0.setImage(R.Icon.arrowNextBlack24?.withTintColor(R.Color.gray200), for: .disabled)
        }
        
        indexLabel = indexLabel.then {
            $0.textColor = R.Color.black
            $0.font = R.Font.body1
            $0.text = "0 / 0"
        }
        
        stackView = stackView.then {
            $0.axis = .horizontal
            $0.distribution = .equalCentering
            $0.alignment = .center
        }
    }
    
    override func setHierarchy() {
        super.setHierarchy()
        addSubviews(stackView)
        stackView.addArrangedSubviews(previousButton, indexLabel, nextButton)
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
