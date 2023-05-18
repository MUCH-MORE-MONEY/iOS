//
//  DetailPageControl.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/05/16.
//

import UIKit
import SnapKit
import Then
import Combine

final class BottomPageControlView: UIView {
    // MARK: - UI Components
    lazy var previousButton = UIButton().then {
        $0.setImage(R.Icon.arrowBackBlack24, for: .normal)
    }
    
    lazy var nextButton = UIButton().then {
        $0.setImage(R.Icon.arrowNextBlack24, for: .normal)
    }
    
    private lazy var indexLabel = UILabel().then {
        $0.font = R.Font.body1
        $0.text = "1 / 5"
    }
    
    private lazy var stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .equalCentering
        $0.alignment = .top
    }
    
    // MARK: - Properties
    
    var index: Int = 0 {
        didSet {
            previousButton.isEnabled = index == 0 ? false : true
            nextButton.isEnabled = index == economicActivityId.count-1 ? false : true
        }
    }
    private var economicActivityId: [String] = []
    private var viewModel: HomeDetailViewModel?
    private lazy var cancellable = Set<AnyCancellable>()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BottomPageControlView {
    // MARK: - Style & Layout
    private func setup() {
        setAttribute()
        setLayout()
        bind()
    }
    
    private func bind() {
        nextButton.tapPublisher.sinkOnMainThread(receiveValue: didTapNextButton)
            .store(in: &cancellable)
        
        previousButton.tapPublisher
            .sinkOnMainThread(receiveValue: didTapPreviousButton)
            .store(in: &cancellable)
    }
    
    private func setAttribute() {
        addSubviews(stackView)
        stackView.addArrangedSubviews(previousButton, indexLabel, nextButton)
    }
    
    private func setLayout() {
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.left.right.bottom.equalToSuperview()
        }
    }
}

// MARK: - Action
extension BottomPageControlView {
    func didTapPreviousButton() {
        if index != 0 {
            index -= 1
            updateView()
        }
    }
    
    func didTapNextButton() {
        if index != economicActivityId.count-1 {
            index += 1
            updateView()
        }
    }
    
    func updateView() {
        let idSize = economicActivityId.count
        indexLabel.text = "\(index+1) / \(idSize)"
        let id = economicActivityId[index]
        viewModel?.fetchDetailActivity(id: id)
    }
    
    func setViewModel(_ viewModel: HomeDetailViewModel, _ index: Int, _ economicActivityId: [String]) {
        self.viewModel = viewModel
        self.economicActivityId = economicActivityId
        self.index = index
        let idSize = economicActivityId.count
        indexLabel.text = "\(index+1) / \(idSize)"
    }
}