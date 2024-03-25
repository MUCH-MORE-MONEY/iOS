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
	
	static func getPayList() -> [Self] {
		return [
			CategoryBar(title: "", price: "", ratio: 38.2),
			CategoryBar(title: "", price: "", ratio: 31),
			CategoryBar(title: "", price: "", ratio: 15),
			CategoryBar(title: "", price: "", ratio: 6),
			CategoryBar(title: "", price: "", ratio: 5),
			CategoryBar(title: "", price: "", ratio: 2)
		]
	}
	
	static func getEarnList() -> [Self] {
		return [
			CategoryBar(title: "", price: "", ratio: 65.2),
			CategoryBar(title: "", price: "", ratio: 15),
			CategoryBar(title: "", price: "", ratio: 8),
			CategoryBar(title: "", price: "", ratio: 3),
			CategoryBar(title: "", price: "", ratio: 4),
			CategoryBar(title: "", price: "", ratio: 2)
		]
	}
}
