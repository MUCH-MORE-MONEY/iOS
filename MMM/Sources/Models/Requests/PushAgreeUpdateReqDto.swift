//
//  PushAgreeUpdateReqDto.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/08/31.
//

import Foundation

/// Push Update에 들어갈 Request 파라미터
struct PushAgreeUpdateReqDto: Encodable {
    var pushAgreeDvcd: String
    var pushAgreeYN: String
}
