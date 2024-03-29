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
import SwiftKeychainWrapper
import Combine

final class OnboardingViewController: UIViewController {
    // MARK: - UI Components
    private var onboardingViews: [UIImageView] = []
    private lazy var scrollView = UIScrollView()
    private lazy var pageControl = UIPageControl()
    private lazy var mainLabel1 = UILabel()
    private lazy var mainLabel2 = UILabel()
    private lazy var subLabel = UILabel()
    private lazy var appleButton = ASAuthorizationAppleIDButton()
    private lazy var guideButton = UIButton()
    
    // MARK: - properites
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
    
    private var currentPage = 0
    private var onboardingVM = OnboardingViewModel(authorizationCode: "", email: "", identityToken: "", userIdentifier: "")
    private var cancellable = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // status text color 변경
    }
}

// MARK: - Actions

extension OnboardingViewController: CustomAlertDelegate {
    @objc func showWebView() {
        if let url = URL(string: "https://talk.naver.com/ct/w40igt") {
            UIApplication.shared.open(url)
        }
    }
    
    private func pageControlTapped() {
        let current = pageControl.currentPage
        scrollView.setContentOffset(
            CGPoint(x: CGFloat(current)*view.frame.size.width,
                    y: 0),
            animated: true)
    }
    
    @objc func appleButtonTapped() {
        
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self as? ASAuthorizationControllerPresentationContextProviding
        controller.performRequests()
    }
    
    // 확인 버튼 이벤트 처리
    func didAlertCofirmButton() {}
    
    // 취소 버튼 이벤트 처리
    func didAlertCacelButton() {}
    
    func labelAnimation(_ labels: UILabel...) {
        if currentPage != pageControl.currentPage {
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
}

// MARK: - Scrollview delegate
extension OnboardingViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let value = Int(round(scrollView.contentOffset.x/scrollView.frame.size.width))
        pageControl.currentPage = value
        
        mainLabel1.text = onboardingItems[value].mainLabel1
        mainLabel2.text = onboardingItems[value].mainLabel2
        subLabel.text = onboardingItems[value].subLabel
        
        labelAnimation(mainLabel1, mainLabel2, subLabel)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let value = Int(round(scrollView.contentOffset.x/scrollView.frame.size.width))
        currentPage = value
    }
}

// MARK: - Apple Login Delegate
extension OnboardingViewController: ASAuthorizationControllerDelegate {
    // 성공 후 동작
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
        
            guard let identityToken = credential.identityToken else { return }
            let identityTokenStr = String(data: identityToken, encoding: .utf8) ?? ""
            
            guard let authorizationCode = credential.authorizationCode else { return }
            let authorizationCodeStr = String(data: authorizationCode, encoding: .utf8) ?? ""
            let userIdentifier = credential.user
        
            /// 최초 로그인 시 credential에서 email 들어옴
            var email = credential.email ?? ""
            /// 2번째 애플 로그인부터는 email이 identityToken에 들어있음.
            if email.isEmpty {
                if let tokenString = String(data: credential.identityToken ?? Data(), encoding: .utf8) {
                    email = onboardingVM.decode(jwtToken: tokenString)["email"] as? String ?? ""
                }
            }
            onboardingVM.appleLogin(authorizationCodeStr, email, identityTokenStr, userIdentifier)
        }
    }
    
    // 실패 후 동작
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("로그인 실패")
    }
}
//MARK: - Attribute & Hierarchy & Layouts
private extension OnboardingViewController {
    
    private func setup() {
        bind()
        setAttribute()
        setLayout()
    }
    
    private func bind() {
//        appleButton.tapPublisher
//            .sinkOnMainThread(receiveValue: appleButtonTapped)
//            .store(in: &cancellable)
        
        guideButton.tapPublisher
            .sinkOnMainThread(receiveValue: showWebView)
            .store(in: &cancellable)
        
        pageControl.tapPublisher
            .sinkOnMainThread(receiveValue: pageControlTapped)
            .store(in: &cancellable)
    }
    
    private func setAttribute() {
        // [view]
        view.backgroundColor = R.Color.white
        
        onboardingItems.forEach {
            onboardingViews.append(UIImageView(image: $0.image))
        }
        
        onboardingViews.forEach {
            $0.contentMode = .scaleAspectFit
            $0.layer.masksToBounds = true
            $0.backgroundColor = R.Color.gray900
        }
        
        labelAnimation(mainLabel1, mainLabel2, subLabel)
        
        scrollView = scrollView.then {
            $0.delegate = self
            $0.showsVerticalScrollIndicator = false
            $0.showsHorizontalScrollIndicator = false
            $0.isScrollEnabled = true
            $0.isPagingEnabled = true
            $0.bounces = false // 경계 지점 scroll 유무
            $0.contentSize.width = view.frame.width * CGFloat(2)
        }
        
        pageControl = pageControl.then {
            $0.numberOfPages = 2
            $0.pageIndicatorTintColor = R.Color.gray200
            $0.currentPageIndicatorTintColor = R.Color.orange500
            $0.isUserInteractionEnabled = false
        }
        
        mainLabel1 = mainLabel1.then {
            $0.text = "내 하루를 돌아보며"
            $0.font = R.Font.h2
            $0.textColor = R.Color.gray800
            $0.textAlignment = .center
        }
        
        mainLabel2 = mainLabel2.then {
            $0.text = "가계부를 작성해요"
            $0.font = R.Font.h2
            $0.textColor = R.Color.orange500
            $0.textAlignment = .center
        }
        
        subLabel = subLabel.then {
            $0.text = "MMM과 함께 수입과 지출을 작성하며\n 그날의 하루를 돌아봐요"
            $0.font = R.Font.body1
            $0.textColor = R.Color.gray500
            $0.textAlignment = .center
            $0.numberOfLines = 2
        }
        
        appleButton = appleButton.then {
            $0.addTarget(self, action: #selector(appleButtonTapped), for: .touchUpInside)
        }
        
        guideButton = guideButton.then {
            $0.setTitle("로그인 중 문제가 발생하셨나요?", for: .normal)
            $0.titleLabel?.font = R.Font.body3
            $0.setTitleColor(R.Color.gray500, for: .normal)
            $0.setTitleColor(R.Color.gray500.withAlphaComponent(0.7), for: .highlighted) // click시 색상
        }
    }
    
    private func setLayout() {
        // [view]
        view.addSubviews(scrollView, mainLabel1, mainLabel2, subLabel, pageControl, appleButton, guideButton)
        
        onboardingViews.forEach {
            scrollView.addSubview($0)
        }
        
		let isSmall = UIScreen.main.bounds.size.height <= 667.0 // 4.7 inch

        scrollView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
			$0.bottom.equalToSuperview().multipliedBy(isSmall ? 0.51 : 0.57) // 비율로 조절
        }
		
        // 온보딩 이미지의 크기 변경 사항
        onboardingViews[0].snp.makeConstraints {
            $0.top.left.equalToSuperview()
            $0.width.equalToSuperview()
			$0.height.equalToSuperview()
        }
		
        // 온보딩 이미지의 크기 변경 사항
        onboardingViews[1].snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.width.equalToSuperview()
            $0.left.equalTo(onboardingViews[0].snp.right)
            $0.height.equalToSuperview()
        }
        
        mainLabel1.snp.makeConstraints {
            $0.top.equalTo(onboardingViews[0].snp.bottom).offset(24)
            $0.left.right.equalToSuperview()
        }
        
        mainLabel2.snp.makeConstraints {
            $0.top.equalTo(mainLabel1.snp.bottom)
            $0.left.right.equalToSuperview()
        }
        
        subLabel.snp.makeConstraints {
            $0.top.equalTo(mainLabel2.snp.bottom).offset(16)
            $0.left.right.equalToSuperview()
        }
        
        pageControl.snp.makeConstraints {
			$0.top.equalTo(subLabel.snp.bottom).offset(32)
            $0.centerX.equalToSuperview()
        }
        
		appleButton.snp.makeConstraints {
			$0.left.right.equalToSuperview().inset(24)
			$0.bottom.equalTo(guideButton.snp.top).offset(-16)
			$0.height.equalTo(40)
		}
		
        guideButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(100)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
        }
    }
}
