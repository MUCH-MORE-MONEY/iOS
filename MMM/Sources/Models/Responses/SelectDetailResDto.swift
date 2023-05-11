//
//  SelectDetailReqResDto.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/05/11.
//

import Foundation

struct SelectDetailResDto: Codable {
    let id: String              // 고유 id
    let amount: String          // 수입/지출에 대한 양
    let type: String            // 수입(01)/지출(02)
    let groupName: String       // 속해 있는 그룹 이름
    let groupNo: String         // 속해 있는 그룹 number
    let title: String           // 제목
    let memo: String            // subtitle
    let createAt: String        // 생성일
    let imageUrl: String        // image url
    let star: Int               // 별 개수
    
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
