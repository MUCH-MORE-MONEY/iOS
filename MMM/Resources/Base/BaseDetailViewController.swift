//
//  BaseDetailViewController.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/05/08.
//

import UIKit
import Then
import SnapKit

class BaseDetailViewController: BaseViewController {
    // MARK: - UI Components
    private lazy var headerView = UIView().then {
        $0.backgroundColor = R.Color.gray900
    }
    
    private lazy var containerStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .center
    }
    
    lazy var totalPrice = UILabel().then {
        $0.font = R.Font.h2
        $0.textColor = R.Color.gray100
    }
    
    private lazy var activityType = BasePaddingLabel().then {
        $0.font = R.Font.body4
        $0.textColor = R.Color.gray100
        $0.backgroundColor = R.Color.orange500
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 4
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

private extension BaseDetailViewController {
    private func setup() {
        setAttribute()
        setLayout()
    }
    
    private func setAttribute() {
        totalPrice.text = "2,000,000원"
        activityType.text = "지출"
        
        view.addSubviews(headerView, containerStackView)
        
        [totalPrice, activityType].forEach {
            containerStackView.addArrangedSubview($0)
        }
    }
    
    private func setLayout() {
        headerView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(124)
        }
        
        containerStackView.snp.makeConstraints {
            $0.left.equalToSuperview().inset(24)
            $0.right.equalToSuperview().inset(163)
            $0.bottom.equalTo(headerView.snp.bottom).inset(24)
        }
        
    }
}
