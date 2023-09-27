//
//  CategoryHeader.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/23.
//

import Foundation

struct CategoryHeaderList: Codable {
	let selectListUpperOutputDto: [CategoryHeader]
}

struct CategoryHeader: Codable, Equatable {
	let id: Int
	let title, price: String
	
	// 파라미터 이름 변경
	enum CodingKeys: String, CodingKey {
		case id = "upperOrderNum"
		case title = "upperEconomicActivityCategoryNm"
		case price = "upperEconomicActivityCategoryCd"
	}
	
	static func getDummyList() -> [Self] {
		return [
			CategoryHeader(id: 1, title: "보기만해도 배부르르르르르으은", price: "2000"),
			CategoryHeader(id: 2, title: "먹고사는 식사사아아", price: "2000"),
			CategoryHeader(id: 3, title: "풍요로운 식사", price: "2000"),
			CategoryHeader(id: 4, title: "삶의 퀄리티티", price: "2000"),
			CategoryHeader(id: 5, title: "보기만해도 배부르르르르르으은", price: "2000")
		]
	}
}
