//
//  MyAPI.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/08/29.
//

import Foundation
import Moya

enum MyAPI {
    case push(PushRequest)
}

extension MyAPI: Moya.TargetType {
    var baseURL: URL { self.getBaseURL() }
    var path: String { self.getPath() }
    var method: Moya.Method { self.getMethod() }
    var sampleData: Data { Data() }
    var task: Task { self.getTask() }
    var headers: [String: String]? { ["Content-Type": "application/json"] }
}
