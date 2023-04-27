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

final class OnboardingViewController: UIViewController {
    // MARK: - UI Components
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
    private lazy var pageControl = UIPageControl().then {
        $0.numberOfPages = 2
        $0.pageIndicatorTintColor = R.Color.gray200
        $0.currentPageIndicatorTintColor = R.Color.orange500
        $0.isUserInteractionEnabled = false
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
    
    private lazy var appleButton = ASAuthorizationAppleIDButton().then {
        $0.addTarget(self, action: #selector(appleButtonTapped), for: .touchUpInside)
    }
    
    private lazy var guideButton = UIButton().then {
        $0.setTitle("로그인 중 문제가 발생하셨나요?", for: .normal)
        $0.titleLabel?.font = R.Font.body3
        $0.setTitleColor(R.Color.gray500, for: .normal)
        $0.setTitleColor(R.Color.gray500.withAlphaComponent(0.7), for: .highlighted) // click시 색상
        $0.addTarget(self, action: #selector(showWebView), for: .touchUpInside)
    }
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // status text color 변경
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
            $0.bottom.equalTo(scrollView.snp.top).offset(464)
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
    
}

// MARK: - Actions

extension OnboardingViewController: CustomAlertDelegate {
    @objc func showWebView() {
        if let url = URL(string: "https://talk.naver.com/ct/w40igt") {
            UIApplication.shared.open(url)
        }
    }
    
    @objc func pageControlTapped() {
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
        controller.delegate = self as? ASAuthorizationControllerDelegate
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

extension OnboardingViewController: ASAuthorizationControllerDelegate {
    // 성공 후 동작
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            let idToken = credential.identityToken!
            let tokeStr = String(data: idToken, encoding: .utf8)
            print("identityToken : \(tokeStr)")
            
            guard let code = credential.authorizationCode else { return }
            let codeStr = String(data: code, encoding: .utf8)
            print("authorizationCode : \(codeStr)")
            
            let user = credential.user
            print("userIdentifier : \(user)")
            
            var email = credential.email ?? ""
            print("첫번째 email : \(email)")
            
            if email.isEmpty {/// 2번째 애플 로그인부터는 email이 identityToken에 들어있음.
                
                if let tokenString = String(data: credential.identityToken ?? Data(), encoding: .utf8) {
                    email = decode(jwtToken: tokenString)["email"] as? String ?? ""
                    print("두번째 email : \(email)")
                }
            }
            onboardingVM.authorizationCode = codeStr
            onboardingVM.email = email
            onboardingVM.identityToken = tokeStr
            onboardingVM.userIdentifier = user
            
            onboardingVM.loginServices()
        }
    }
    
    /// JWTToken -> dictionary
    private func decode(jwtToken jwt: String) -> [String: Any] {
        
        func base64UrlDecode(_ value: String) -> Data? {
            var base64 = value
                .replacingOccurrences(of: "-", with: "+")
                .replacingOccurrences(of: "_", with: "/")
            
            let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
            let requiredLength = 4 * ceil(length / 4.0)
            let paddingLength = requiredLength - length
            if paddingLength > 0 {
                let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
                base64 = base64 + padding
            }
            return Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
        }
        
        func decodeJWTPart(_ value: String) -> [String: Any]? {
            guard let bodyData = base64UrlDecode(value),
                  let json = try? JSONSerialization.jsonObject(with: bodyData, options: []), let payload = json as? [String: Any] else {
                return nil
            }
            
            return payload
        }
        
        let segments = jwt.components(separatedBy: ".")
        return decodeJWTPart(segments[1]) ?? [:]
    }
    
    // 실패 후 동작
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("로그인 실패")
    }
}
