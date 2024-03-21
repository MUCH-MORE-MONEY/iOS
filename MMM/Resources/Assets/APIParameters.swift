//
//  APIParameters.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/05/01.
//

import Foundation

protocol DictionaryConvertor: Codable {}

//MARK: APIParameters for using in URLrequests
/// urlrequest에 전달하는 데 필요한 모든 매개변수를 포함하는 구조체
/// it is conforimig to DictionaryConvertor
struct APIParameters{
    struct LoginReqDto: Encodable {
        var authorizationCode: String?
        var email: String?
        var identityToken: String?
        var pushToken: String?
        var userIdentifier: String?
    }
    
    struct SelectListDailyReqDto: Encodable {
        var dateYMD: Int?
    }
    
    struct SelectDetailReqDto: Encodable {
        var economicActivityNo: String?
    }
    
    struct SelectListMonthlyReqDto: Encodable {
        var dateYM: Int?
    }
    
    /// 새로운 경제활동 등록을 위한 Request
    struct InsertEconomicActivityReqDto: Encodable {
        var binaryFileList: [BinaryFileList]
        var amount: Int
        var category: String?
        var type: String
        var title: String
        var memo: String
        var createAt: String
        var star: Int
        var recurrenceInfo: RecurrenceInfo?
        var recurrenceYN: String
        
        enum CodingKeys: String, CodingKey {
            case binaryFileList
            case category = "economicActivityCategoryCd"
            case type = "economicActivityDvcd"
            case amount = "economicActivityAmt"
            case title = "economicActivityNm"
            case memo = "economicActivityMm"
            case createAt = "economicActivityYMD"
            case star = "valueScore"
            case recurrenceInfo
            case recurrenceYN
        }
    }
    
    /// 기존 경제활동 수정을 위한 Request
    struct UpdateReqDto: Encodable {
        var binaryFileList: [BinaryFileList]
        var amount: Int
        var category: String?
        var type: String
        var title: String
        var memo: String
        var id: String
        var createAt: String
        var fileNo: String
        var star: Int
        
        enum CodingKeys: String, CodingKey {
            case binaryFileList
            case fileNo
            case category = "economicActivityCategoryCd"
            case type = "economicActivityDvcd"
            case amount = "economicActivityAmt"
            case title = "economicActivityNm"
            case memo = "economicActivityMm"
            case id = "economicActivityNo"
            case createAt = "economicActivityYMD"
            case star = "valueScore"
        }
    }
    /// update와 insert에 사용하는 이미지 binaryfile struct
    struct BinaryFileList: Codable {
        let binaryData: String
        let fileNm: String
    }
    
    struct RecurrenceInfo: Encodable {
        var endYMD: String //"endYMD": "20240510",
        var recurrenceCnt: Int //"recurrenceCnt": 3,
        var recurrenceEndDvcd: String   // "recurrenceEndDvcd": "01",
        var recurrencePattern: String   // "recurrencePattern": "none",
        var startYMD: String            //  "startYMD": "20240510"
    }
    
    /// 경제활동 삭제를 위한 Request
    struct DeleteReqDto: Encodable {
        let id: String
        let delRecurrenceYn: String
        enum CodingKeys: String, CodingKey {
            case id = "economicActivityNo"
            case delRecurrenceYn
        }
    }
	
	/// 경제활동 Excel 데이터 전환을 위한 Request
	struct ExportReqDto: Encodable {
	}
	
	/// 경제활동 요약를 위한 Request
	struct SummaryReqDto: Encodable {
	}
	
	/// 탈퇴를 위한 Request
	struct WithdrawReqDto: Encodable {
	}
    
    /// 카테고리 조회
    struct CategoryListReqDto: Encodable {
    }
}

struct APIHeader {
    struct Default: Encodable {
        var token: String?
    }
}
