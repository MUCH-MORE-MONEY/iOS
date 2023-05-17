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

final class DetailPageControlView: UIView {
    // MARK: - UI Components
    private lazy var previousButton = UIButton().then {
        $0.setImage(R.Icon.arrowBackBlack24, for: .normal)
    }
    
    private lazy var nextButton = UIButton().then {
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
    
    private var index: Int = 0
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

extension DetailPageControlView {
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
            $0.edges.equalToSuperview()
        }
        previousButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
        }

        indexLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
        }

        nextButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
        }
    }
}

// MARK: - Action
extension DetailPageControlView {
    func didTapPreviousButton() {
        if index != 0 {
            let idSize = economicActivityId.count
            print("PreviousButton")
            index -= 1
            indexLabel.text = "\(index+1) / \(idSize)"
            let id = economicActivityId[index]
            viewModel?.fetchDetailActivity(id: id)
            print(id)
        }
    }
    
    func didTapNextButton() {
        if index != economicActivityId.count-1 {
            let idSize = economicActivityId.count
            print("NextButotn")
            index += 1
            indexLabel.text = "\(index+1) / \(idSize)"
            let id = economicActivityId[index]
            viewModel?.fetchDetailActivity(id: id)
            print(id)

        }
    }
    
    func setViewModel(_ viewModel: HomeDetailViewModel, _ index: Int, _ economicActivityId: [String]) {
        self.viewModel = viewModel
        self.index = index
        self.economicActivityId = economicActivityId
        let idSize = economicActivityId.count
        indexLabel.text = "\(index+1) / \(idSize)"
    }
}