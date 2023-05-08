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
	var economicActivityTotalIncomeSumAmt: Int	// 총 수입
	var economicActivityTotalSpentSumAmt: Int	// 총 지출
	var selectListMonthlyOutputDto: [Monthly]?
}
