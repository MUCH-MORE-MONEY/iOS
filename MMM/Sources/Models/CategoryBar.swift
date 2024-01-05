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

struct CategoryBar: Codable, Equatable {
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
			CategoryBar(title: "최고의 구매애애", price: "가격", ratio: 48.5),
			CategoryBar(title: "최고의 구매애애", price: "가격", ratio: 48.5),
			CategoryBar(title: "높은 안모오오옥", price: "가격", ratio: 3.0),
			CategoryBar(title: "높은 안모오오옥", price: "가격", ratio: 2.0)
		]
	}
}
