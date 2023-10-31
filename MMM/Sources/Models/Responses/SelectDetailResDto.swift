//
//  SelectDetailReqResDto.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/05/11.
//

import Foundation

struct SelectDetailResDto: Codable {
    let id: String              // 고유 id
    let amount: Int          // 수입/지출에 대한 양
    let categoryID: String?   // 카테고리 id
    let categoryName: String? // 카테고리 이름
    let type: String            // 수입(01)/지출(02)
//    let groupName: String       // 속해 있는 그룹 이름
//    let groupNo: String         // 속해 있는 그룹 number
    let title: String           // 제목
    let memo: String            // subtitle
    let createAt: String        // 생성일
    let fileNo: String
    let imageUrl: String        // image url
    let star: Int               // 별 개수
    
    enum CodingKeys: String, CodingKey {
        case id = "economicActivityNo"
        case amount = "economicActivityAmt"
        case categoryID = "economicActivityCategoryCd"
        case categoryName = "economicActivityCategoryNm"
        case type = "economicActivityDvcd"
//        case groupName = "economicActivityGroupNm"
//        case groupNo = "economicActivityGroupNo"
        case title = "economicActivityNm"
        case memo = "economicActivityMm"
        case createAt = "economicActivityYMD"
        case imageUrl = "fileUrl"
        case fileNo
        case star = "valueScore"
    }
}
