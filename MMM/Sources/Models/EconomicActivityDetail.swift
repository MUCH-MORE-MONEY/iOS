//
//  EconomicActivityDetail.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/05/11.
//

import Foundation

struct EconomicActivityDetail: Codable {
    let id: String
    let amount: String
    let type: String
    let groupName: String
    let groupNo: String
    let title: String
    let memo: String
    let createAt: String
    let imageUrl: String
    let star: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "economicActivityNo"
        case amount = "economicActivityAmt"
        case type = "economicActivityDvcd"
        case groupName = "economicActivityGroupNm"
        case groupNo = "economicActivityGroupNo"
        case title = "economicActivityMm"
        case memo = "economicActivityNm"
        case createAt = "economicActivityYMD"
        case imageUrl = "fileUrl"
        case star = "valueScore"
    }
}
