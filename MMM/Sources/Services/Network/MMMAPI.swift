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
    case push
}

extension MMMAPI: TargetType {
    
    /// baseURL
    var baseURL: URL {
        return URL(string: APIConstants.baseURL)!
    }
    
    /// router에 사용될 세부 경로
    var path: String {
        switch self {
        case .push:
            return "/push"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .push:
            return .post
        }
    }
    
    /// get 방식의 parameter를 넘길 때 사용
    var task: Moya.Task {
        <#code#>
    }

    
    // FIXME: - Header token으로 수정
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
    

}
