//
//  BinaryFileList.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/05/27.
//

import Foundation

struct InsertEconomicActivity: Codable {
    var binaryFileList: [BinaryFileList]
    var amount: Int
    var type: String
    var title: String
    var memo: String
    var createAt: String
    var star: Int
    
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
