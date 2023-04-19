//
//  Calendar.swift
//  MMM
//
//  Created by geonhyeong on 2023/04/18.
//

import Foundation

struct Calendar: Identifiable, Equatable {
	let id: String = UUID().uuidString
	let isEarn: Bool		// 수입/지출
	let title: String
	let memo: String		// 메모
	let price: Int
	let star: Int
	let image: String		// 이미지
	
	static func getDummyList() -> [Self] {
		return [
			Calendar(isEarn: true, title: "당근마켓", memo: "당근마켓으로 그동안 안 쓰고 있던 미니무드등을 팔았고", price: 50000, star: 4, image: ""),
			Calendar(isEarn: false, title: "자취 기념 식물", memo: "", price: 100000, star: 2, image: "test"),
			Calendar(isEarn: true, title: "용돈", memo: "이번달부터 10만원 올랐음", price: 500000, star: 0, image: ""),
			Calendar(isEarn: false, title: "소설책소설책소설책소설책소설책소설책소설책소설책소설책소설책소설책소설책소설책소설책소설책", memo: "당근마켓으로 그동안 안 쓰고 있던 미니무드등을 팔았고 당근마켓으로 그동안 안 쓰고 있던 미니무드등을 팔았고 ", price: 25000, star: 5, image: "")
		]
	}
}
