//
//  APIConstants.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/04/25.
//

import Foundation

enum APIConstants {
    static let baseURL = "http://ec2-13-209-4-42.ap-northeast-2.compute.amazonaws.com:8080"
}

enum HTTPHeaderField: String {
    case authentication = "Authentication"
    case contentType = "Content-Type"
    case acceptType = "Accept"
    case acceptEncoding = "Accept-Encoding"
    case authorization = "Authorization"
    case acceptLanguage = "Accept-Language"
    case userAgent = "User-Agent"
}

enum ContentType: String {
    case json = "application/json"
    case xwwwformurlencoded = "application/x-www-form-urlencoded"
}

