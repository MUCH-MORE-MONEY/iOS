//
//  Category.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/24.
//

import Foundation

struct Category: Codable, Equatable {
	let id, title, dateYM: String
	let total, orderNum: Int
	let ratio: Double
	let lowwer: [CategoryLowwer]

	// 파라미터 이름 변경
	enum CodingKeys: String, CodingKey {
		case id = "upperEconomicActivityCategoryCd"
		case title = "upperEconomicActivityCategoryNm"
		case total = "upperEconomicActivityCategorySumAmt"
		case orderNum = "upperOrderNum"
		case dateYM = "dateYM"
		case ratio = "economicActivityCategoryRatio"
		case lowwer = "selectListMonthlyEconomicActivityByCategoryOutputDto"
	}
	
	static func getHeader() -> Self {
		return Category(id: "header", title: "", dateYM: "", total: -1, orderNum: -1, ratio: -1, lowwer: [])
	}
}

struct CategoryLowwer: Codable, Equatable {
	let id, title: String
	let total, orderNum: Int
	
	// 파라미터 이름 변경
	enum CodingKeys: String, CodingKey {
		case id = "economicActivityCategoryCd"
		case title = "economicActivityCategoryNm"
		case total = "economicActivityCategorySumAmt"
		case orderNum = "orderNum"
	}
	
	static func getHeader() -> Self {
		return CategoryLowwer(id: "header", title: "", total: -1, orderNum: -1)
	}
}
