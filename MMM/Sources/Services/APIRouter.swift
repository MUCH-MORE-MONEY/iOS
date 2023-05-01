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
    struct AppleLoginReqDto: Request {
        typealias ReturnType = AppleLoginResDto
        var path: String = "/login/apple"
        var method: HTTPMethod = .post
        var body: [String : Any]?
        init(body: APIParameters.LoginReqDto) {
            self.body = body.asDictionary
        }
    }
}
