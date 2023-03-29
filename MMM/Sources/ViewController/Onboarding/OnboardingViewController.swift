//
//  OnboardingViewController.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/03/29.
//

import UIKit
import Then
import SnapKit

final class OnboardingViewController: UIViewController {
    
    private let onboardingView = OnboardingView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

//MARK: - Style & Layouts
private extension OnboardingViewController {
    
    private func setup() {
        // 초기 셋업할 코드들
        setAttribute()
        setLayout()
    }
    
    private func setAttribute() {
        // [view]
        view.backgroundColor = .systemBackground
        view.addSubviews(onboardingView)
    }
    
    private func setLayout() {
        // [view]
        onboardingView.snp.makeConstraints {
            $0.top.left.right.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(464)
        }
    }
}
