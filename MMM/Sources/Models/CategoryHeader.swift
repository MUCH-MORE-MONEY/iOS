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
}
