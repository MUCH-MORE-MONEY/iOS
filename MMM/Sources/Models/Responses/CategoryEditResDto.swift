//
//  CategoryResDto.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/16.
//

import Foundation

/// 경제활동카테고리 목록 조회 API Response를 위한 데이터 타입
struct CategoryEditResDto: Codable {
	var data: CategoryEditList?
	var message: String?
	var status: String
}

/// 경제활동상위카테고리 목록 조회 API Response를 위한 데이터 타입
struct CategoryEditHeaderResDto: Codable {
	var data: CategoryHeaderList
	var message: String?
	var status: String
}

/// 경제활동구분 코드 기준 카테고리별 월간 경제활동 목록 전체 조회 Response를 위한 데이터 타입
struct CategoryListResDto: Codable {
	var data: [Category]
	var message: String?
	var status: String
}

/// 카테고리코드 기준 월간 경제활동 상세 목록 조회 Response를 위한 데이터 타입
struct CategoryDetailListResDto: Decodable {
	var data: SelectListMonthlyByCategoryCdOutputDto
	var message: String?
	var status: String
}

struct SelectListMonthlyByCategoryCdOutputDto: Decodable {
	var selectListMonthlyByCategoryCdOutputDto: [EconomicActivity]
}
