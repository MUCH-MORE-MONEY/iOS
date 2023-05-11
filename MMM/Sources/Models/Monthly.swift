//
//  Monthly.swift
//  MMM
//
//  Created by geonhyeong on 2023/05/08.
//

import Foundation

struct Monthly: Codable, Identifiable, Equatable {
	let id: String = UUID().uuidString
	let earn: Int			// 총 수입
	let pay: Int			// 총 지출
	let total: Int			// 수입 지출 합
	let createAt: String	// 생성일
	
	// 파라미터 이름 변경
	enum CodingKeys: String, CodingKey {
		case earn = "economicActivityIncomeSumAmt"
		case pay = "economicActivitySpentSumAmt"
		case total = "economicActivitySumAmt"
		case createAt = "dateYMD"
	}
	
	static func getDummyList() -> [Self] {
		return [
			Monthly(earn: 40000, pay: -10000, total: 30000, createAt: "20230405"),
			Monthly(earn: 30000, pay: -50000, total: -20000, createAt: "20230404")
		]
	}
}
