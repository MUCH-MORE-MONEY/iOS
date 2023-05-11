//
//  DetailViewController.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/05/08.
//

import UIKit
import Then
import SnapKit
import Combine

class DetailViewController: BaseDetailViewController {
    // MARK: - UI Components
    private lazy var starContainer = UIStackView().then {
        $0.axis = .vertical
    }
    
    private lazy var editButton = UIBarButtonItem().then {
        $0.title = "편집"
        $0.style = .plain
        $0.target = self
        $0.action = #selector(didTapEditButton)
    }
    
    private lazy var titleLabel = UILabel().then {
        $0.font = R.Font.body0
        $0.textColor = R.Color.gray200
    }
    
    // MARK: - Properties
    private var viewModel = HomeDetailViewModel()
    private var economicActivityId: [String] = []
    private var index: Int = 0
    private var cancellable = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

extension DetailViewController {
    func setData(economicActivityId: [String], index: Int) {
        self.economicActivityId = economicActivityId
        self.index = index
    }
    
    private func setup() {
        bind()
        setAttribute()
        setLayout()
    }
    
    private func bind() {
        viewModel.$detailActivity
            .sinkOnMainThread { [weak self] value in
                guard let self = self, let value = value else { return }
                self.titleLabel.text = value.title
            }.store(in: &cancellable)
        
        viewModel.fetchDetailActivity(id: economicActivityId[index])
    }
    
    private func setAttribute() {
        

        navigationItem.rightBarButtonItem = editButton
        view.addSubviews(starContainer, titleLabel)
    }
    
    private func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.left.equalToSuperview().inset(24)
            $0.right.equalToSuperview().inset(135)
            $0.bottom.equalTo(totalPrice.snp.top).offset(-8)
        }
    }
}

// MARK: - Action
private extension DetailViewController {
    @objc func didTapEditButton(_ sener: UITapGestureRecognizer) {
        print("edit Tapped")
        print(viewModel.detailActivity?.title)
    }
}
