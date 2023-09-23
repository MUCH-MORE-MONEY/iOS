//
//  CategoryResDto.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/16.
//

import Foundation

/// Category Response를 위한 데이터 타입
struct CategoryResDto: Codable {
	var data: CategoryList
	var message: String?
	var status: String
}

/// Category Header Response를 위한 데이터 타입
struct CategoryHeaderResDto: Codable {
	var data: CategoryHeaderList
	var message: String?
	var status: String
}

/// Category List Response를 위한 데이터 타입
struct CategoryListResDto: Decodable {
	var data: SelectListMonthlyByCategoryCdOutputDto
	var message: String?
	var status: Int
}

struct SelectListMonthlyByCategoryCdOutputDto: Decodable {
	var selectListMonthlyByCategoryCdOutputDto: [EconomicActivity]
}
