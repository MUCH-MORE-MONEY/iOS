//
//  EconomicActivityResDto.swift
//  MMM
//
//  Created by geonhyeong on 2023/05/02.
//

import Foundation

/// daily/list/select api
struct EconomicActivityDailyResDto: Codable {
	var message: String
	var selectListDailyOutputDto: [EconomicActivity]
}
