//
//  Category.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/16.
//

import Foundation

struct CategoryList: Codable {
	let selectListOutputDto: [Category]
}

struct Category: Codable {
	let title, price, upperTitle, upperPrice: String
	let id, upperId: Int
	
	// 파라미터 이름 변경
	enum CodingKeys: String, CodingKey {
		case title = "economicActivityCategoryNm"
		case price = "economicActivityCategoryCd"
		case id = "orderNum"
		case upperTitle = "upperEconomicActivityCategoryNm"
		case upperPrice = "upperEconomicActivityCategoryCd"
		case upperId = "upperOrderNum"
	}
	
	static func getDummy() -> Self {
		return Category(title: "덕질비용", price: "10000", upperTitle: "보기만 해도 배부른", upperPrice: "10000", id: 1, upperId: 1)
	}

}
