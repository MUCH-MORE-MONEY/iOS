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
		return CategoryEdit(id: "01", title: "하위 카테고리", upperId: "01", upperTitle: "상위 카테고리", orderNum: 1, upperOrderNum: 1)
	}
}

// 수정을 위한 모델
struct CategoryEditUpperPut: Codable, Equatable {
	var id, title, useYn: String
	var list: [CategoryEditPut]
	
	// 파라미터 이름 변경
	enum CodingKeys: String, CodingKey {
		case id = "upperEconomicActivityCategoryCd"
		case title = "upperEconomicActivityCategoryNm"
		case useYn = "useYn"
		case list = "economicActivityCategoryList"
	}
	
	static func == (lhs: CategoryEditUpperPut, rhs: CategoryEditUpperPut) -> Bool {	
		return lhs.id == rhs.id && lhs.title == rhs.title && lhs.list == rhs.list
	}
}

struct CategoryEditPut: Codable, Equatable {
	var id, title, useYn: String
	
	// 파라미터 이름 변경
	enum CodingKeys: String, CodingKey {
		case id = "economicActivityCategoryCd"
		case title = "economicActivityCategoryNm"
		case useYn = "useYn"
	}
	
	static func == (lhs: CategoryEditPut, rhs: CategoryEditPut) -> Bool {
		return lhs.id == rhs.id && lhs.title == rhs.title
	}
}

