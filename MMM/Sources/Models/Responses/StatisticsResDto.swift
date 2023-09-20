//
//  StatisticsResDto.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/14.
//

import Foundation

struct StatisticsAvgResDto: Decodable {
	var economicActivityValueScoreAvg: Double
	var message: String
}

/// /economic_activity/{dateYM}/{valueScoreDvcd}/list
struct StatisticsListResDto: Decodable {
	var message: String?
	var nextOffset: Int
	var selectListMonthlyByValueScoreOutputDto: [EconomicActivity]
}
