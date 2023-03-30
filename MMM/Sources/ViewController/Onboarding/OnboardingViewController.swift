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
    private let onboardingView1 = OnboardingView()
    private lazy var scrollView = UIScrollView()
    private let pageControl = UIPageControl()
    
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
        setupScrollView()
        setupPageControl()
        onboardingView1.setUp(image: R.Icon.onboarding2 ?? UIImage(),
                              label1: "더 나은 내 소비를 위해",
                              label2: "리뷰를 작성해보세요",
                              label3: "다음에 돈을 어떻게 쓰고 벌지 \n다시 한 번 생각하고 다짐해요")
    }
    
    private func setLayout() {
        // [view]
        view.addSubviews(scrollView, pageControl)
        scrollView.addSubviews(onboardingView, onboardingView1)

        scrollView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalToSuperview().inset(118)
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
    }
    
    private func setupScrollView() {
        scrollView.delegate = self // scroll범위에 따라 pageControl의 값을 바꾸어주기 위한 delegate
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isScrollEnabled = true
        scrollView.isPagingEnabled = true
        scrollView.bounces = false // 경계 지점 scroll 유무

        scrollView.contentSize.width = view.frame.width * CGFloat(2)
    }
    
    private func setupPageControl() {
        pageControl.currentPage = 0
        pageControl.numberOfPages = 2
        pageControl.pageIndicatorTintColor = R.Color.gray200
        pageControl.currentPageIndicatorTintColor = R.Color.orange500
    }
    
    private func setPageControlSelectedPage(currentPage: Int) {
        pageControl.currentPage = currentPage
    }
}

// MARK: - Scrollview delegate
extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let value = scrollView.contentOffset.x/scrollView.frame.size.width
        setPageControlSelectedPage(currentPage: Int(round(value)))
    }
}
