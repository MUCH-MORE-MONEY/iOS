//
//  DetailViewController.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/05/08.
//

import UIKit
import Then
import SnapKit

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
    private var economicActivityId: [String] = []
    private var index: Int = 0
    
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
        setAttribute()
        setLayout()
    }
    
    private func setAttribute() {
        titleLabel.text = "스타벅스 나들이를 해봤습니다!"
        navigationItem.rightBarButtonItem = editButton
        view.addSubviews(starContainer, titleLabel)
        title = economicActivityId[index]
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
    }
}
