//
//  PushResDto.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/08/29.
//

import Foundation

struct PushResDto: Decodable {
    var message: String
}

struct PushAgreeUpdateResDto: Decodable {
    var message: String
}

struct PushAgreeListSelectResDto: Decodable {
    var message: String
    var selectedList: [SelectedList]
    
    struct SelectedList: Decodable {
        var pushAgreeDvcd: String
        var pushAgreeYN: String
    }
    
    enum CodingKeys: String, CodingKey {
        case message
        case selectedList = "selectListPushAgreeOutputDto"
    }
}
