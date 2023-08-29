//
//  PushRequest.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/08/29.
//

import Foundation

/// Push에 들어갈 Request 파라미터
struct PushRequest: ModelType {
    var content: String
    var pushAgreeDvcd: String
}
