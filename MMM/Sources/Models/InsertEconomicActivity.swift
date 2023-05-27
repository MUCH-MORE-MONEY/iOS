//
//  BinaryFileList.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/05/27.
//

import Foundation

struct InsertEconomicActivity: Codable {
    let binaryFileList: [BinaryFileList]
    let amount: Int
    let type: String
    let title: String
    let memo: String
    let createAt: Int
    let star: Int
    
    enum CodingKeys: String, CodingKey {
        case binaryFileList
        case type = "economicActivityDvcd"
        case amount = "economicActivityAmt"
        case title = "economicActivityMm"
        case memo = "economicActivityNm"
        case createAt = "economicActivityYMD"
        case star = "valueScore"
    }
}


// MARK: - BinaryFileList
struct BinaryFileList: Codable {
    let binaryData: String
    let fileNm: String
}
