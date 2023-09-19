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
