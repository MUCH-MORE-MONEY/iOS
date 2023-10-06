//
//  CategoryMainSectionModel.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/16.
//

import RxDataSources
import Foundation

// AnimatableSectionModel: 자동으로 셀 애니메이션 관리
typealias CategoryMainSectionModel = AnimatableSectionModel<CategoryMainSection, CategoryMainItem>

enum CategoryMainSection {
	case base(Category, [CategoryMainItem])
}

enum CategoryMainItem: IdentifiableType, Equatable {
	case base(CategoryCollectionViewCellReactor)
	
	// IdentifiableType에 의한 identity 설정
	var identity: some Hashable {
		switch self {
		case let .base(reactor):
			return reactor.currentState.categoryLowwer.id
		}
	}
	
	// 비교를 위한 함수
	static func == (lhs: CategoryMainItem, rhs: CategoryMainItem) -> Bool {
		lhs.identity == rhs.identity
	}
}
// MARK: - AnimatableSectionModelType Protocol
extension CategoryMainSection: AnimatableSectionModelType {
	typealias Item = CategoryMainItem
	
	// 준수해야할 Property
	var identity: String {
		return "\(items.count)"
	}
	
	var items: [Item] {
		switch self {
		case .base(_, let items):
			return items
		}
	}
	
	var header: Category {
		switch self {
		case .base(let header, _):
			return header
		}
	}
	
	init(original: CategoryMainSection, items: [CategoryMainItem]) {
		switch original {
		case .base(let header, let items):
			self = .base(header, items)
		}
	}
}
