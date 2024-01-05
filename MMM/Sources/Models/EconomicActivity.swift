//
//  EconomicActivity.swift
//  MMM
//
//  Created by geonhyeong on 2023/04/18.
//

import Foundation

struct EconomicActivity: Codable, Identifiable, Equatable {
	let id: String
	let type: String			// 지출(01)/수입(02)
	let group: String?
	let categoryId: String?		// 속해 있는 카테고리 Id
	let categoryTitle: String?	// 속해 있는 카테고리 이름
	let title: String			// 이름
	let memo: String			// 메모
	let amount: Int				// 양
	let star: Int				// 별 개수
	let imageUrl: String		// 이미지 url
	let createAt: String		// 생성일
    let rowNum: Int?            // index
    
	// 파라미터 이름 변경
	enum CodingKeys: String, CodingKey {
		case id = "economicActivityNo"
		case type = "economicActivityDvcd"
		case group = "economicActivityGroupNm"
		case categoryId = "economicActivityCategoryCd"
		case categoryTitle = "economicActivityCategoryNm"
        case title = "economicActivityNm"
        case memo = "economicActivityMm"
		case amount = "economicActivityAmt"
		case star = "valueScore"
		case imageUrl = "economicActivityThumbnailUrl"
		case createAt = "economicActivityYMD"
        case rowNum
	}
	
	static func getDummyList() -> [Self] {
		return [
            EconomicActivity(id: "000001", type: "01", group: "01", categoryId: "1", categoryTitle: "소비", title: "당근마켓", memo: "당근마켓으로 그동안 안 쓰고 있던 미니무드등을 팔았고", amount: 50000, star: 4, imageUrl: "", createAt: "20230512", rowNum: 1),
            EconomicActivity(id: "000002", type: "02", group: "01", categoryId: "1", categoryTitle: "소비", title: "자취 기념 식물", memo: "", amount: 100000, star: 2, imageUrl: "String", createAt: "20230512", rowNum: 2),
            EconomicActivity(id: "000003", type: "01", group: "01", categoryId: "1", categoryTitle: "지출", title: "용돈", memo: "이번달부터 10만원 올랐음", amount: 500000, star: 0, imageUrl: "", createAt: "20230512", rowNum: 3),
            EconomicActivity(id: "000004", type: "02", group: "01", categoryId: "1", categoryTitle: "소비",  title: "소설책소설책소설책소설책소설책소설책소설책소설책소설책소설책소설책소설책소설책소설책소설책", memo: "당근마켓으로 그동안 안 쓰고 있던 미니무드등을 팔았고 당근마켓으로 그동안 안 쓰고 있던 미니무드등을 팔았고 ", amount: 25000, star: 5, imageUrl: "", createAt: "20230512", rowNum: 4)
		]
	}
	
	static func getThreeDummyList() -> [Self] {
		return [
            EconomicActivity(id: "000001", type: "01", group: "01", categoryId: "1", categoryTitle: "소비", title: "자취 기념 식물입니다아아아", memo: "당근마켓으로 그동안 안 쓰고 있던 미니무드등을 팔았고", amount: 50000, star: 4, imageUrl: "", createAt: "20230512", rowNum: 1),
            EconomicActivity(id: "000002", type: "02", group: "01", categoryId: "1", categoryTitle: "소비", title: "자취 기념 식물", memo: "", amount: 100000, star: 2, imageUrl: "String", createAt: "20230512", rowNum: 2),
            EconomicActivity(id: "000003", type: "01", group: "01", categoryId: "1", categoryTitle: "소비", title: "용돈", memo: "이번달부터 10만원 올랐음", amount: 500000, star: 0, imageUrl: "", createAt: "20230512", rowNum: 3),
		]
	}
}
