//
//  CategoryDetailSectionModel.swift
//  MMM
//
//  Created by geonhyeong on 11/30/23.
//

import RxDataSources
import Foundation

// AnimatableSectionModel: 자동으로 셀 애니메이션 관리
typealias CategoryDetailSectionModel = AnimatableSectionModel<String, CategoryDetailItem>

enum CategoryDetailItem: IdentifiableType, Equatable {
	case base(EconomicActivity)
	case skeleton

	// IdentifiableType에 의한 identity 설정
	var identity: some Hashable {
		switch self {
		case let .base(economicActivity):
			return economicActivity.id
		case .skeleton:
			return ""
		}
	}
	
	// 비교를 위한 함수
	static func == (lhs: CategoryDetailItem, rhs: CategoryDetailItem) -> Bool {
		lhs.identity == rhs.identity
	}
}
