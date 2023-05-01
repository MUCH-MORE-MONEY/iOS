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
    
    struct ProductParams: Encodable  {
        var skip: Int?
        var limit: Int?
    }
    
    struct AddProductParams: Encodable {
        var title: String?
    }
    
    struct LoginReqDtoParams: Encodable {
        var authorizationCode: String?
        var email: String?
        var identityToken: String?
        var userIdentifier: String?
    }
}
