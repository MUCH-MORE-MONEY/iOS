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
    /// 일별 세부 경제활동을 위한 Router
    struct SelectDetailReqDto: Request {
        typealias ReturnType = SelectDetailResDto
        var path: String = "/economic_activity/detail/select"
        var method: HTTPMethod = .post
        var headers: [String : String]?
        var body: [String: Any]?
        
        init(headers: APIHeader.Default, body: APIParameters.SelectDetailReqDto) {
            self.headers = headers.asDictionary as? [String: String]
            self.body = body.asDictionary
        }
    }
	
	/// 월별 경제 활동 List를 위한 Router
	struct SelectListMonthlyReqDto: Request {
		typealias ReturnType = EconomicActivitySelectListMonthlyResDto
		var path: String = "/economic_activity/monthly/select"
		var method: HTTPMethod = .post
		var headers: [String:String]?
		var body: [String : Any]?
		
		init(headers: APIHeader.Default, body: APIParameters.SelectListMonthlyReqDto) {
			self.headers = headers.asDictionary as? [String: String]
			self.body = body.asDictionary
		}
	}
    
    /// 신규 경제활동 등록을 위한 Router
    struct InsertReqDto: Request {
        typealias ReturnType = InsertResDto
        var path: String = "/economic_activity/insert"
        var method: HTTPMethod = .post
        var headers: [String : String]?
        var body: [String : Any]?
        
        init(headers: APIHeader.Default, body: APIParameters.InsertEconomicActivityReqDto) {
            self.headers = headers.asDictionary as? [String: String]
            self.body = body.asDictionary
        }
    }
    
    /// 기존 경제활동 수정을 위한 Router
    struct UpdateReqDto: Request {
        typealias ReturnType = UpdateResDto
        var path: String = "/economic_activity/update"
        var method: HTTPMethod = .post
        var headers: [String : String]?
        var body: [String: Any]?
        
        init(headers: APIHeader.Default, body: APIParameters.UpdateReqDto) {
            self.headers = headers.asDictionary as? [String: String]
            self.body = body.asDictionary
        }
    }
    
    /// 경제활동 삭제를 위한 Router
    struct DeleteReqDto: Request {
        typealias ReturnType = DeleteResDto
        var path: String = "/economic_activity/delete"
        var method: HTTPMethod = .post
        var headers: [String : String]?
        var body: [String : Any]?
        
        init(headers: APIHeader.Default, body: APIParameters.DeleteReqDto) {
            self.headers = headers.asDictionary as? [String: String]
            self.body = body.asDictionary
        }
    }
}
