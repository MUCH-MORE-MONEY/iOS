//
//  Category.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/16.
//

import Foundation

struct CategoryEditList: Codable {
	let selectListOutputDto: [CategoryEdit]
}

struct CategoryEdit: Codable, Equatable {
	let id, title, upperId, upperTitle : String
	let orderNum, upperOrderNum: Int
	
	// 파라미터 이름 변경
	enum CodingKeys: String, CodingKey {
		case id = "economicActivityCategoryCd"
		case title = "economicActivityCategoryNm"
		case orderNum = "orderNum"
		case upperId = "upperEconomicActivityCategoryCd"
		case upperTitle = "upperEconomicActivityCategoryNm"
		case upperOrderNum = "upperOrderNum"
	}
	
	static func getDummy() -> Self {
		return CategoryEdit(id: "01", title: "덕질비요요요요용덕질비요요요요용", upperId: "01", upperTitle: "보기만 해도 배부른", orderNum: 1, upperOrderNum: 1)
	}

}
