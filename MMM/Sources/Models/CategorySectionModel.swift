//
//  CategorySectionModel.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/16.
//

import RxDataSources
import Foundation

// AnimatableSectionModel: 자동으로 셀 애니메이션 관리
typealias CategorySectionModel = AnimatableSectionModel<String, CategoryItem>

//enum CategorySection {
//	case base([CategoryItem])
//}

enum CategoryItem: IdentifiableType, Equatable {
	case base(CategoryCollectionViewCellReactor)
	
	// IdentifiableType에 의한 identity 설정
	var identity: some Hashable {
		switch self {
		case let .base(reactor):
			return reactor.currentState.category.id
		}
	}
	
	// 비교를 위한 함수
	static func == (lhs: CategoryItem, rhs: CategoryItem) -> Bool {
		lhs.identity == rhs.identity
	}
}
//// MARK: - AnimatableSectionModelType Protocol
//extension CategorySection: AnimatableSectionModelType {
//	typealias Item = CategoryItem
//
//	// 준수해야할 Property
//	var identity: String {
//		return "\(items.count)"
//	}
//
//	var items: [Item] {
//		switch self {
//		case .base(let items):
//			return items
//		}
//	}
//
//	init(original: CategorySection, items: [CategoryItem]) {
//		switch original {
//		case .base(let items):
//			self = .base(items)
//		}
//	}
//}
