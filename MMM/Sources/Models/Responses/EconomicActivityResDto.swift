//
//  EconomicActivityResDto.swift
//  MMM
//
//  Created by geonhyeong on 2023/05/02.
//

import Foundation

/// daily/list/select api
struct EconomicActivitySelectListDailyResDto: Codable {
	var message: String?
	var selectListDailyOutputDto: [EconomicActivity]?
}

/// /monthly/select
struct EconomicActivitySelectListMonthlyResDto: Codable {
	var message: String?
	var earn: Int	// 총 수입
	var pay: Int	// 총 지출
	var monthly: [Monthly]?
	
	// 파라미터 이름 변경
	enum CodingKeys: String, CodingKey {
		case earn = "economicActivityTotalIncomeSumAmt"
		case pay = "economicActivityTotalSpentSumAmt"
		case monthly = "selectListMonthlyOutputDto"
	}
}
