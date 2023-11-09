//
//  WidgetResDto.swift
//  MMM
//
//  Created by geonhyeong on 11/10/23.
//

import Foundation

struct WidgetResDto: Codable {
	var data: EconomicWeekly
	var message: String?
	var status: String
}

struct EconomicWeekly: Codable {
	var weekly: Int
	
	// 파라미터 이름 변경
	enum CodingKeys: String, CodingKey {
		case weekly = "weeklyEconomicActivityCnt"
	}
}
