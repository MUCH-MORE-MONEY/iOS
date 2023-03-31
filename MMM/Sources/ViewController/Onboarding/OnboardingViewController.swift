//
//  OnboardingViewController.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/03/29.
//

import UIKit
import Then
import SnapKit
import AuthenticationServices
import WebKit

final class OnboardingViewController: UIViewController {
    
    private let onboardingView = OnboardingView()
    private let onboardingView1 = OnboardingView()
    private var webView: WKWebView!
    
    
    private lazy var scrollView = UIScrollView().then {
        $0.delegate = self
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.isScrollEnabled = true
        $0.isPagingEnabled = true
        $0.bounces = false // 경계 지점 scroll 유무
        $0.contentSize.width = view.frame.width * CGFloat(2)
    }
    private let pageControl = UIPageControl().then {
        $0.currentPage = 0
        $0.numberOfPages = 2
        $0.pageIndicatorTintColor = R.Color.gray200
        $0.currentPageIndicatorTintColor = R.Color.orange500
    }
    
    private let appleButton = ASAuthorizationAppleIDButton().then {_ in
        
    }
    
    private let guideButton = UIButton().then {
        $0.setTitle("로그인 중 문제가 발생하셨나요?", for: .normal)
        $0.titleLabel?.font = R.Font.body3
        $0.setTitleColor(R.Color.gray500, for: .normal)
        $0.addTarget(self, action: #selector(showWebView), for: .touchUpInside)
    }
    
    
    
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
        
        onboardingView1.setUp(image: R.Icon.onboarding2 ?? UIImage(),
                              label1: "더 나은 내 소비를 위해",
                              label2: "리뷰를 작성해보세요",
                              label3: "다음에 돈을 어떻게 쓰고 벌지 \n다시 한 번 생각하고 다짐해요")
    }
    
    private func setLayout() {
        // [view]
        view.addSubviews(scrollView, pageControl, appleButton, guideButton)
        scrollView.addSubviews(onboardingView, onboardingView1)
        
        scrollView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.bottom.equalToSuperview().inset(188 + 48) // bottom + label2 height
        }
        
        pageControl.snp.makeConstraints {
            $0.top.equalTo(scrollView.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
        }
        
        onboardingView.snp.makeConstraints {
            $0.top.left.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.equalTo(464)
        }
        onboardingView1.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.width.equalToSuperview()
            $0.left.equalTo(onboardingView.snp.right)
            $0.height.equalTo(464)
        }
        
        appleButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(24)
            $0.top.equalTo(pageControl.snp.bottom).offset(24)
            $0.height.equalTo(40)
        }
        
        guideButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(100)
            $0.top.equalTo(appleButton.snp.bottom).offset(16)
        }
        
        
    }
    
    private func setPageControlSelectedPage(currentPage: Int) {
        pageControl.currentPage = currentPage
    }
    
}

// MARK: - Actions

extension OnboardingViewController {
    @objc func showWebView() {
        if let url = URL(string: "https://talk.naver.com/ct/w40igt") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Scrollview delegate
extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let value = scrollView.contentOffset.x/scrollView.frame.size.width
        setPageControlSelectedPage(currentPage: Int(round(value)))
    }
}
