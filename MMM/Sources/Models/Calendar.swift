//
//  Calendar.swift
//  MMM
//
//  Created by geonhyeong on 2023/04/18.
//

import Foundation

struct Calendar: Identifiable, Equatable {
	let id: String = UUID().uuidString
	let isIncome: Bool		// 수입/지출
	let title: String
	let content: String		// 메모
	let price: Int
	let star: Int
	let image: String		// 이미지
	
	static func getDummyList() -> [Self] {
		return [
			Calendar(isIncome: true, title: "당근마켓", content: "당근마켓으로 그동안 안 쓰고 있던 미니무드등을 팔았고", price: 50000, star: 5, image: ""),
			Calendar(isIncome: false, title: "자취 기념 식물", content: "", price: 100000, star: 5, image: ""),
			Calendar(isIncome: true, title: "용돈", content: "이번달부터 10만원 올랐음", price: 500000, star: 0, image: ""),
			Calendar(isIncome: false, title: "당근마켓", content: "당근마켓으로 그동안 안 쓰고 있던 미니무드등을 팔았고", price: 50000, star: 5, image: "")
		]
	}
}
