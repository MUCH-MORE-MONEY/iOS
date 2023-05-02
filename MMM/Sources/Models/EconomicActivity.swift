//
//  EconomicActivity.swift
//  MMM
//
//  Created by geonhyeong on 2023/04/18.
//

import Foundation

struct EconomicActivity: Codable, Identifiable, Equatable {
	let id: String = UUID().uuidString
	let type: String		// 수입(01)/지출(02)
	let groupNo: String		// 속해 있는 그룹
	let title: String		// 이름
	let memo: String		// 메모
	let amount: Int			// 양
	let star: Int			// 별 개수
	let imageUrl: String	// 이미지 url
	let createAt: String	// 생성일
	
	// 파라미터 이름 변경
	enum CodingKeys: String, CodingKey {
		case id = "economicActivityNo"
		case type = "economicActivityDvcd"
		case groupNo = "economicActivityGroupNm"
		case title = "economicActivityMm"
		case memo = "economicActivityNm"
		case amount = "economicActivityAmt"
		case star = "valueScore"
		case imageUrl = "economicActivityThumbnailUrl"
		case createAt = "economicActivityYMD"
	}
	
	static func getDummyList() -> [Self] {
		return [
			EconomicActivity(type: "01", groupNo: "1", title: "당근마켓", memo: "당근마켓으로 그동안 안 쓰고 있던 미니무드등을 팔았고", amount: 50000, star: 4, imageUrl: "", createAt: "20230405"),
			EconomicActivity(type: "02", groupNo: "1", title: "자취 기념 식물", memo: "", amount: 100000, star: 2, imageUrl: "String", createAt: "20230405"),
			EconomicActivity(type: "01", groupNo: "1", title: "용돈", memo: "이번달부터 10만원 올랐음", amount: 500000, star: 0, imageUrl: "", createAt: "20230405"),
			EconomicActivity(type: "02", groupNo: "1", title: "소설책소설책소설책소설책소설책소설책소설책소설책소설책소설책소설책소설책소설책소설책소설책", memo: "당근마켓으로 그동안 안 쓰고 있던 미니무드등을 팔았고 당근마켓으로 그동안 안 쓰고 있던 미니무드등을 팔았고 ", amount: 25000, star: 5, imageUrl: "", createAt: "20230405")
		]
	}
}
