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
    
    init(authorizationCode: String, email: String, identityToken: String, userIdentifier: String) {
        self.authorizationCode = authorizationCode
        self.email = email
        self.identityToken = identityToken
        self.userIdentifier = userIdentifier
    }
    
    func loginServices() {
        let url = APIConstants.baseURL
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10
        
        let params =  ["authorizationCode": authorizationCode,
                       "email": email,
                       "identityToken": identityToken,
                       "userIdentifier": userIdentifier
        ] as Dictionary
        
        // httpBody 에 parameters 추가
        do {
            try request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
        } catch {
            print("http Body Error")
        }
        AF.request(request).responseString { (response) in
            switch response.result {
            case .success:
                print("POST 성공")
                guard let data = response.data else { return }
                do {
                    let decoder = JSONDecoder()
                    let json = try decoder.decode(LoginResponse.self, from: data)
                    Constants.setKeychain(json.token, forKey: Constants.KeychainKey.accessToken)
                } catch {
                    print("데이터 파싱 실패")
                }
                
                // 로그인 성공 시 tabbar로 메인 뷰 전환
                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                    let tabBarController = TabBarController()
                    sceneDelegate.window?.rootViewController = tabBarController
                }
                
            case .failure(let error):
                print("error : \(error.errorDescription!)")
            }
        }
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
