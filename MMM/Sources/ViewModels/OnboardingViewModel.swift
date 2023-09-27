//
//  OnboardingViewModel.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/04/12.
//

import Foundation
import Combine
import UIKit
import SwiftKeychainWrapper

final class OnboardingViewModel {
    var authorizationCode: String? = ""
    var email: String? = ""
    var identityToken: String? = ""
    var userIdentifier: String? = ""
    var cancellable: Set<AnyCancellable> = []
    
    init(authorizationCode: String, email: String, identityToken: String, userIdentifier: String) {
        self.authorizationCode = authorizationCode
        self.email = email
        self.identityToken = identityToken
        self.userIdentifier = userIdentifier
    }
    
    func appleLogin(_ authorizationCode: String, _ email: String, _ identityToken: String, _ userIdentifier: String) {
        guard let pushToken = Constants.getKeychainValue(forKey: Constants.KeychainKey.pushToken) else { return }
        
//        debugPrint(authorizationCode)
//        debugPrint(email)
//        debugPrint(identityToken)
//        debugPrint(pushToken)
//        debugPrint(userIdentifier)
        
        APIClient.dispatch(
            APIRouter.AppleLoginReqDto(body:
                                        APIParameters.LoginReqDto(
                                            authorizationCode: authorizationCode,
                                            email: email,
                                            identityToken: identityToken,
                                            pushToken: pushToken,
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
            self.authorizationCode = authorizationCode
            self.email = email
            self.identityToken = identityToken
            self.userIdentifier = userIdentifier
            
            // 사용자의 이메일 저장
            Constants.setKeychain(email, forKey: Constants.KeychainKey.email)
            // 사용자 token 저장
            Constants.setKeychain(value.token, forKey: Constants.KeychainKey.token)

            // 로그인 성공 시 tabbar로 메인 뷰 전환
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                let tabBarController = NavigationController(rootViewController: TabBarController(widgetIndex: 0))
                sceneDelegate.window?.rootViewController = tabBarController
            }
        })
        .store(in: &cancellable)
    }
    
    /// JWTToken -> dictionary
    func decode(jwtToken jwt: String) -> [String: Any] {
        
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
}
