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
        var path: String = "/v2/economic_activity/detail"
        var method: HTTPMethod = .get
        var queryParams: [String : Any]?
        var headers: [String : String]?
        
        init(headers: APIHeader.Default, queryParams: APIParameters.SelectDetailReqDto) {
            self.headers = headers.asDictionary as? [String: String]
            self.queryParams = queryParams.asDictionary
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
        var path: String = "/v2/economic_activity"
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
        var path: String = "/v2/economic_activity"
        var method: HTTPMethod = .put
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
        var path: String = "/v2/economic_activity"
        var method: HTTPMethod = .delete
        var headers: [String : String]?
        var queryParams: [String : Any]?
        
        init(headers: APIHeader.Default, queryParams: APIParameters.DeleteReqDto) {
            self.headers = headers.asDictionary as? [String: String]
            self.queryParams = queryParams.asDictionary
        }
    }
	
	/// 경제활동 Excel 데이터 전환 위한 Router
	struct ExportReqDto: Request {
		typealias ReturnType = ExportResDto
		var path: String = "/economic_activity/excel/select"
		var method: HTTPMethod = .post
		var headers: [String : String]?
		var body: [String : Any]?
		
		init(headers: APIHeader.Default, body: APIParameters.ExportReqDto) {
			self.headers = headers.asDictionary as? [String: String]
			self.body = body.asDictionary
		}
	}
	
	/// 경제활동 요약를 위한 Router
	struct SummaryReqDto: Request {
		typealias ReturnType = SummaryResDto
		var path: String = "/economic_activity/summary/select"
		var method: HTTPMethod = .post
		var headers: [String : String]?
		var body: [String : Any]?
		
		init(headers: APIHeader.Default, body: APIParameters.SummaryReqDto) {
			self.headers = headers.asDictionary as? [String: String]
			self.body = body.asDictionary
		}
	}
	
	/// 회원탈퇴
	struct WithdrawReqDto: Request {
		typealias ReturnType = WithdrawResDto
		var path: String = "/login/delete"
		var method: HTTPMethod = .post
		var headers: [String : String]?
		var body: [String : Any]?
		
		init(headers: APIHeader.Default, body: APIParameters.WithdrawReqDto) {
			self.headers = headers.asDictionary as? [String: String]
			self.body = body.asDictionary
		}
	}
    
    /// 월간 카테고리 조회
    struct CategoryListReqDto: Request {
        typealias ReturnType = CategoryListResDto
        var path: String = "/economic_activity"
        var method: HTTPMethod = .get
        var headers: [String : String]?
        var body: [String : Any]?
        
        init(headers: APIHeader.Default, dateYM: String, dvcd: String) {
            self.headers = headers.asDictionary as? [String: String]
            self.path += "/\(dateYM)/\(dvcd)/category/list"
        }
    }

	/// 해당 일자 기준 주간 경제활동 작성 갯수조회
	struct WidgetReqDto: Request {
		typealias ReturnType = WidgetResDto
		var path: String = "/economic_activity"
		var method: HTTPMethod = .get
		var headers: [String : String]?
		var body: [String : Any]?
		
		init(headers: APIHeader.Default, dateYMD: String) {
			self.headers = headers.asDictionary as? [String: String]
			self.path += "/\(dateYMD)/weekly"
		}
	}
}
