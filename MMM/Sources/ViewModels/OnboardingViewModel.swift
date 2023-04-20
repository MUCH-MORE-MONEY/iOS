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
        let url = "http://ec2-13-209-4-42.ap-northeast-2.compute.amazonaws.com:8080/login/apple"
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
