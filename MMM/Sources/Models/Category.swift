//
//  Category.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/16.
//

import Foundation

struct CategoryList: Codable {
	let CategoryList: [Category]
}

struct Category: Codable {
	let id, type, upperId, upperType: String
	let order, upperOrder: Int
	
	// 파라미터 이름 변경
	enum CodingKeys: String, CodingKey {
		case id = "economicActivityCategoryNm"
		case type = "economicActivityCategoryCd"
		case order = "orderNum"
		case upperId = "upperEconomicActivityCategoryNm"
		case upperType = "upperEconomicActivityCategoryCd"
		case upperOrder = "upperOrderNum"
	}
}
