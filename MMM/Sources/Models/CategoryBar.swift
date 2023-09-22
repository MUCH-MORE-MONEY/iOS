//
//  CategoryBar.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/22.
//

import Foundation

struct CategoryBarList: Codable {
	let setSelectListMonthlyByUpperCategoryOutputDto: [CategoryBar]
}

struct CategoryBar: Codable {
	let title, price: String
	let ratio: Double
	
	// 파라미터 이름 변경
	enum CodingKeys: String, CodingKey {
		case title = "economicActivityCategoryNm"
		case price = "economicActivityCategoryCd"
		case ratio = "economicActivityCategoryRatio"
	}
	
	static func getDummy() -> Self {
		return CategoryBar(title: "제목", price: "가격", ratio: 100)
	}

	static func getDummyList() -> [Self] {
		return [
			CategoryBar(title: "알찬 소비", price: "가격", ratio: 70),
			CategoryBar(title: "최고의 구매", price: "가격", ratio: 20),
			CategoryBar(title: "높은 안목", price: "가격", ratio: 10)
		]
	}
}
