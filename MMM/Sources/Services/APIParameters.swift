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
            case title = "economicActivityNm"
            case memo = "economicActivityMm"
            case createAt = "economicActivityYMD"
            case star = "valueScore"
        }
    }
    
    /// 기존 경제활동 수정을 위한 Request
    struct UpdateReqDto: Encodable {
        var binaryFileList: [BinaryFileList]
        var amount: Int
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
    
    /// 경제활동 삭제를 위한 Request
    struct DeleteReqDto: Encodable {
        var id: String
        
        enum CodingKeys: String, CodingKey {
            case id = "economicActivityNo"
        }
    }
}

struct APIHeader {
    struct Default: Encodable {
        var token: String?
    }
}
