//
//  APIRouter.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/05/01.
//

import Foundation

/// API 라우터
final class APIRouter {
    
    /// 애플 로그인을 위한 Router
    struct AppleLogin: Request {
        typealias ReturnType = LoginResponse
        var path: String = "/login/apple"
        var method: HTTPMethod = .post
        var body: [String : Any]?
        init(body: APIParameters.LoginReqDtoParams) {
            self.body = body.asDictionary
        }
    }
}
