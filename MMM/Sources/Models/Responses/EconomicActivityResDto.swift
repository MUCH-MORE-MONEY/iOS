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
