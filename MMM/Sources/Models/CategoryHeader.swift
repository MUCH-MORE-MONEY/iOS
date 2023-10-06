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
	let id, title: String
	let orderNum: Int

	// 파라미터 이름 변경
	enum CodingKeys: String, CodingKey {
		case id = "upperEconomicActivityCategoryCd"
		case title = "upperEconomicActivityCategoryNm"
		case orderNum = "upperOrderNum"
	}
	
	static func getFooter() -> Self {
		return CategoryHeader(id: "footer", title: "", orderNum: 0)
	}
	
	static func getDummyList() -> [Self] {
		return [
			CategoryHeader(id: "1", title: "보기만해도 배부르르르르르으은", orderNum: 1),
			CategoryHeader(id: "2", title: "먹고사는 식사사아아", orderNum: 2),
			CategoryHeader(id: "3", title: "풍요로운 식사", orderNum: 3),
			CategoryHeader(id: "4", title: "삶의 퀄리티티", orderNum: 4),
			CategoryHeader(id: "5", title: "보기만해도 배부르르르르르으은", orderNum: 5)
		]
	}
}
