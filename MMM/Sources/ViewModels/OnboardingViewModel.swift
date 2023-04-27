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
        let url = APIConstant.baseURL
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
                    let json = try decoder.decode(Login.self, from: data)
                    Common.setKeychain(json.token, forKey: Common.KeychainKey.authorization)
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
}
