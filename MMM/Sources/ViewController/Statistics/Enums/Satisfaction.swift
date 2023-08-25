//
//  Satisfaction.swift
//  MMM
//
//  Created by geonhyeong on 2023/08/25.
//

enum Satisfaction: Int {
	case low	// 1~2점
	case middle	// 3점
	case hight	// 4~5점
	
	var title: String {
		switch self {
		case .low: return "아쉬운 활동 줄이기"
		case .middle: return "평범한 활동 돌아보기"
		case .hight: return "만족스러운 활동 늘리기"
		}
	}
	
	var score: String {
		switch self {
		case .low: return "1~2점"
		case .middle: return "3점"
		case .hight: return "4~5점"
		}
	}
}
