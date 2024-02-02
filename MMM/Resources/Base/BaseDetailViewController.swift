//
//  BaseDetailViewController.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/05/08.
//

import UIKit
import Then
import SnapKit

class BaseDetailViewController: BaseViewControllerWithNav {
    // MARK: - UI Components
    lazy var headerView = UIView().then {
        $0.backgroundColor = R.Color.gray900
    }
    
    lazy var containerStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .center
    }
    
    lazy var totalPrice = UILabel().then {
        $0.font = R.Font.h2
        $0.textColor = R.Color.gray100
        $0.sizeToFit()
    }
    
    var activityType = BasePaddingLabel().then {
        $0.font = R.Font.body4
        $0.textColor = R.Color.gray100
        $0.backgroundColor = R.Color.orange500
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 4
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension BaseDetailViewController {
//    func setData(totalPrice: String) {
//        DispatchQueue.main.async {
//            self.totalPrice.text = totalPrice
//        }
//
//        print("baseVC total price : ", self.totalPrice.text)
//    }
    
    override func setAttribute() {
		super.setAttribute()
        view.addSubviews(headerView, containerStackView)
        
        [totalPrice, activityType].forEach {
            containerStackView.addArrangedSubview($0)
        }
    }
    
	override func setLayout() {
		super.setLayout()
        headerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(containerStackView.snp.bottom).offset(24)
        }
        
        containerStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(58)
            $0.left.equalToSuperview().inset(24)
        }
    }
}
