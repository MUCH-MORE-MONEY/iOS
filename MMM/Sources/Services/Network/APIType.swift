//
//  MMMAPI.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/08/29.
//

import Foundation
import Moya
import RxSwift

enum MMMAPI {
    // MARK: - Push
    case push(PushReqDto)
    case pushAgreeListSelect
    case pushAgreeUpdate(PushAgreeUpdateReqDto)
    
    // MARK: - Staticstics
}

extension MMMAPI: BaseNetworkService {
    
    /// baseURL
    var baseURL: URL {
        return URL(string: APIConstants.baseURL)!
    }
    
    /// router에 사용될 세부 경로
    var path: String {
        switch self {
        case .push:
            return "/push"
        case .pushAgreeListSelect:
            return "/push/agree/list/select"
        case .pushAgreeUpdate:
            return "/push/agree/update"
        }
    }
    
    /// 메서드 방식 선택
    var method: Moya.Method {
        switch self {
        case .push, .pushAgreeListSelect, .pushAgreeUpdate:
            return .post
        }
    }
    
    /// body parameter
    /// post - JSONEncoding.default
    /// get  -  URLEncoding.default
    /// parameter || body가 없을 경우 .requestPlain 설정
    var task: Moya.Task {
        switch self {
        case .push(let request):
            return .requestParameters(parameters: request.asDictionary, encoding: JSONEncoding.default)
        
        case .pushAgreeListSelect:
            return .requestPlain
            
        case .pushAgreeUpdate(let request):
            return .requestParameters(parameters: request.asDictionary, encoding: JSONEncoding.default)
            
        }
    }

    
    /// Header 전달
    /// nil 일 경우 헤더 요청하지 않음
    /// 값이 들어 있을 경우만 요청
    /// 옵셔널이지만 moya 내부적으로 헤더를 넘겨줌, 클라이언트에서 신경 쓸 필요 없음
    var headers: [String : String]? {
        guard let token = Constants.getKeychainValue(forKey: Constants.KeychainKey.token) else { return nil }
        return APIHeader.Default(token: token).asDictionary as? [String: String]
    }
}
