//
//  Login.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/04/27.
//

import Foundation

/// Apple 로그인 Response를 위한 데이터 타입
struct AppleLoginResDto: Codable {
    var message: String
    var token: String
}

