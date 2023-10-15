//
//  CategoryEdit.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/16.
//

import Foundation

struct CategoryEditList: Codable {
	let selectListOutputDto: [CategoryEdit]
}

struct CategoryEdit: Codable, Equatable {
	let id: String
	var title, upperId, upperTitle: String
	var orderNum, upperOrderNum: Int
	
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

// 수정을 위한 모델
struct CategoryEditUpperPut: Codable {
	var id, title, useYn: String
	var list: [CategoryEditPut]
	
	// 파라미터 이름 변경
	enum CodingKeys: String, CodingKey {
		case id = "upperEconomicActivityCategoryCd"
		case title = "upperEconomicActivityCategoryNm"
		case useYn = "useYn"
		case list = "economicActivityCategoryList"
	}
}

struct CategoryEditPut: Codable {
	var id, title, useYn: String
	
	// 파라미터 이름 변경
	enum CodingKeys: String, CodingKey {
		case id = "economicActivityCategoryCd"
		case title = "economicActivityCategoryNm"
		case useYn = "useYn"
	}
}

