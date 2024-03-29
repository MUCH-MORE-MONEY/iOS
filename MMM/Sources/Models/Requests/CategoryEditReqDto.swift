//
//  CategoryReqDto.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/16.
//

import Foundation

/// Category에 들어갈 Request 파라미터
struct CategoryEditReqDto: Encodable {
	var economicActivityDvcd: String  // 01: 수입, 02: 지출
}

/// Category에 들어갈 Request 파라미터
struct PutCategoryEditReqDto: Encodable {
	var economicActivityDvcd: String  // 01: 수입, 02: 지출
	var data: [CategoryEditUpperPut]
}

/// 카테고리코드 기준 월간 경제활동 상세 목록 조회 API에 들어갈 Request 파라미터
struct CategoryDetailListReqDto: Encodable {
	var dateYM: String
	var economicActivityCategoryCd: String
	var economicActivityDvcd: String
}

/// 경제활동구분 코드 기준 카테고리별 월간 경제활동 목록 전체 조회
/// 01: 지출, 02: 수입
struct CategoryListReqDto: Encodable {
    var dateYM: String
    var economicActivityDvcd: String
}
