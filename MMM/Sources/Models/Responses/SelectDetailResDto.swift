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
    var title: String           // 제목
    var memo: String            // subtitle
    var createAt: String        // 생성일
    var fileNo: String
    var imageUrl: String        // image url
    var star: Int               // 별 개수
    var recurrenceYN: String?
    var recurrenceInfo: RecurrenceInfo?
    
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
        case recurrenceInfo
        case recurrenceYN
    }
    
    struct RecurrenceInfo: Codable, Equatable {
        var endYMD: String //"endYMD": "20240510",
        var recurrenceCnt: Int //"recurrenceCnt": 3,
        var recurrenceEndDvcd: String   // "recurrenceEndDvcd": "01",
        var recurrencePattern: String   // "recurrencePattern": "none",
        var startYMD: String            //  "startYMD": "20240510"
    }
}
