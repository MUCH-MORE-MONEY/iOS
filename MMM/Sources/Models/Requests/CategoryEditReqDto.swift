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

/// 카테고리코드 기준 월간 경제활동 상세 목록 조회 API에 들어갈 Request 파라미터
struct CategoryDetailListReqDto: Encodable {
	var dateYM: String
	var economicActivityCategoryCd: String
	var economicActivityDvcd: String
}
