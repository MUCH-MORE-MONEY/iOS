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
        var type: String
        var title: String
        var memo: String
        var createAt: String
        var star: Int
        
        enum CodingKeys: String, CodingKey {
            case binaryFileList
            case type = "economicActivityDvcd"
            case amount = "economicActivityAmt"
            case title = "economicActivityMm"
            case memo = "economicActivityNm"
            case createAt = "economicActivityYMD"
            case star = "valueScore"
        }
        
        struct BinaryFileList: Codable {
            let binaryData: String
            let fileNm: String
        }
    }
    
    /// 기존 경제활동 수정을 위한 Request
    struct UpdateReqDto: Encodable {
        var binaryFileList: [BinaryFileList]
        var amount: Int
        var type: String
        var title: String
        var memo: String
        var activityNumber: String
        var createAt: String
        var star: Int
        
        enum CodingKeys: String, CodingKey {
            case binaryFileList
            case type = "economicActivityDvcd"
            case amount = "economicActivityAmt"
            case title = "economicActivityMm"
            case memo = "economicActivityNm"
            case activityNumber = "economicActivityNo"
            case createAt = "economicActivityYMD"
            case star = "valueScore"
        }
        
        struct BinaryFileList: Codable {
            let binaryData: String
            let fileNm: String
        }
    }
}

struct APIHeader {
    struct Default: Encodable {
        var token: String?
    }
}
