//
//  InsertResDto.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/05/27.
//

import Foundation

/// 경제활동 수정 및 추가에 대한 Response
struct InsertResDto: Codable {
    var economicActivityNo: String
    var message: String
}
