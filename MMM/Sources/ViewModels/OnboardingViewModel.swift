//
//  OnboardingViewModel.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/04/12.
//

import Foundation
import Combine
import UIKit
import Alamofire
import SwiftKeychainWrapper

final class OnboardingViewModel {
    var authorizationCode: String?
    var email: String?
    var identityToken: String?
    var userIdentifier: String?
    var cancellable: Set<AnyCancellable> = []
    @Published var loginResponse: AppleLoginResDto = AppleLoginResDto(message: "", token: "")
    
    init(authorizationCode: String, email: String, identityToken: String, userIdentifier: String) {
        self.authorizationCode = authorizationCode
        self.email = email
        self.identityToken = identityToken
        self.userIdentifier = userIdentifier
    }
    
    func appleLogin() {
        APIClient.dispatch(
            APIRouter.AppleLoginReqDto(body:
                                        APIParameters.LoginReqDto(
                                            authorizationCode: authorizationCode,
                                            email: email,
                                            identityToken: identityToken,
                                            userIdentifier: userIdentifier)))
        .sink(receiveCompletion: { error in
            switch error {
            case .failure(let data):
                switch data {
                case .error4xx(_):
                    break
                case .error5xx(_):
                    break
                case .decodingError(_):
                    break
                case .urlSessionFailed(_):
                    break
                case .timeOut:
                    break
                case .unknownError:
                    break
                default:
                    break
                }
            case .finished:
                break
            }
        }, receiveValue: { [weak self] value in
            guard let self = self else { return }
            self.loginResponse.message = value.message
            self.loginResponse.token = value.token
            print(value.message)
            // 로그인 성공 시 tabbar로 메인 뷰 전환
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                let tabBarController = TabBarController()
                sceneDelegate.window?.rootViewController = tabBarController
            }
        })
        .store(in: &cancellable)

    }
}
