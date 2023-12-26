//
//  SelectDetailReqResDto.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/05/11.
//

import Foundation

struct SelectDetailResDto: Codable, Equatable {
    var id: String              // 고유 id
    var amount: Int          // 수입/지출에 대한 양
    var categoryID: String      // 카테고리 id
    var categoryName: String    // 카테고리 이름
    var type: String            // 수입(01)/지출(02)
//    let groupName: String       // 속해 있는 그룹 이름
//    let groupNo: String         // 속해 있는 그룹 number
    var title: String           // 제목
    var memo: String            // subtitle
    var createAt: String        // 생성일
    var fileNo: String
    var imageUrl: String        // image url
    var star: Int               // 별 개수
    
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
