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
	
	/// 일별 경제 활동 List를 위한 Router
	struct SelectListDailyReqDto: Request {
		typealias ReturnType = EconomicActivitySelectListDailyResDto
		var path: String = "/economic_activity/daily/list/select"
		var method: HTTPMethod = .post
		var headers: [String:String]?
		var body: [String : Any]?
		
		init(headers: APIHeader.Default, body: APIParameters.SelectListDailyReqDto) {
			self.headers = headers.asDictionary as? [String: String]
			self.body = body.asDictionary
		}
	}
}
