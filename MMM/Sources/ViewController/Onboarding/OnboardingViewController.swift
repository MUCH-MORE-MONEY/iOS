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
    
    private let onboardingItems = [
        OnboardingItem(image: R.Icon.onboarding1!,
                       mainLabel1: "내 하루를 돌아보며",
                       mainLabel2: "가계부를 작성해요",
                       subLabel: "MMM과 함께 수입과 지출을 작성하며\n 그날의 하루를 돌아봐요"),
        OnboardingItem(image: R.Icon.onboarding2!,
                       mainLabel1: "더 나은 내 소비를 위해",
                       mainLabel2: "리뷰를 작성해보세요",
                       subLabel: "다음에 돈을 어떻게 쓰고 벌지 \n다시 한 번 생각하고 다짐해요")
    ]
    
    private var onboardingViews: [UIImageView] = []
    
    
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
        $0.addTarget(self, action: #selector(pageControlTapped), for: .valueChanged)
    }
    
    private lazy var mainLabel1 = UILabel().then {
        $0.text = "내 하루를 돌아보며"
        $0.font = R.Font.h2
        $0.textColor = R.Color.gray800
        $0.textAlignment = .center
    }
    
    private lazy var mainLabel2 = UILabel().then {
        $0.text = "가계부를 작성해요"
        $0.font = R.Font.h2
        $0.textColor = R.Color.orange500
        $0.textAlignment = .center
    }
    
    private lazy var subLabel = UILabel().then {
        $0.text = "MMM과 함께 수입과 지출을 작성하며\n 그날의 하루를 돌아봐요"
        $0.font = R.Font.body1
        $0.textColor = R.Color.gray500
        $0.textAlignment = .center
        $0.numberOfLines = 2
    }
    
    private let appleButton = ASAuthorizationAppleIDButton().then { _ in
//        $0.cornerRadius = 22
//        $0.setTitle("Apple로 계속하기", for: .normal)

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
        onboardingItems.forEach {
            onboardingViews.append(UIImageView(image: $0.image))
        }
        
        onboardingViews.forEach {
            $0.contentMode = .scaleAspectFit
            $0.layer.masksToBounds = true
            $0.backgroundColor = R.Color.gray900
        }
        
        labelAnimation(mainLabel1, mainLabel2, subLabel)
    }
    
    private func setLayout() {
        // [view]
        view.addSubviews(scrollView, mainLabel1, mainLabel2, subLabel, pageControl, appleButton, guideButton)
        
        onboardingViews.forEach {
            scrollView.addSubview($0)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.bottom.equalToSuperview().inset(188 + 48) // bottom + label2 height
        }
        
        onboardingViews[0].snp.makeConstraints {
            $0.top.left.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.equalTo(464)
        }
        
        onboardingViews[1].snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.width.equalToSuperview()
            $0.left.equalTo(onboardingViews[0].snp.right)
            $0.height.equalTo(464)
        }
        
        mainLabel1.snp.makeConstraints {
            $0.top.equalTo(onboardingViews[0].snp.bottom).offset(32)
            $0.left.right.equalToSuperview().inset(100)
        }
        
        mainLabel2.snp.makeConstraints {
            $0.top.equalTo(mainLabel1.snp.bottom)
            $0.left.right.equalToSuperview().inset(100)
        }
        
        subLabel.snp.makeConstraints {
            $0.top.equalTo(mainLabel2.snp.bottom).offset(16)
            $0.left.right.equalToSuperview().inset(70)
        }
        
        pageControl.snp.makeConstraints {
            $0.top.equalTo(subLabel.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
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
    
    @objc func pageControlTapped() {
        
    }
    
    func labelAnimation(_ labels: UILabel...) {
        labels.forEach {
            $0.alpha = 0.0
        }
        
        UIView.animate(withDuration: 0.3) {
            labels.forEach {
                $0.alpha = 1.0
            }
        }
    }
}

// MARK: - Scrollview delegate
extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let value = scrollView.contentOffset.x/scrollView.frame.size.width
        setPageControlSelectedPage(currentPage: Int(round(value)))
        
        mainLabel1.text = onboardingItems[Int(round(value))].mainLabel1
        mainLabel2.text = onboardingItems[Int(round(value))].mainLabel2
        subLabel.text = onboardingItems[Int(round(value))].subLabel
        
        labelAnimation(mainLabel1, mainLabel2, subLabel)

    }
}
