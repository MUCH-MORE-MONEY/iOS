//
//  CategoryReqDto.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/16.
//

import Foundation

/// Category에 들어갈 Request 파라미터
struct CategoryReqDto: Encodable {
	var economicActivityDvcd: String  // 01: 수입, 02: 지출
}
