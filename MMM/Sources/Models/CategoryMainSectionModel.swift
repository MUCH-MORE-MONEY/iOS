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
	case header(CategoryMainItem)
	case base(Category, [CategoryMainItem])
}

enum CategoryMainItem: IdentifiableType, Equatable {
	case header
	case base(CategoryCollectionViewCellReactor)
	case empty
	
	// IdentifiableType에 의한 identity 설정
	var identity: some Hashable {
		switch self {
		case .header, .empty:
			return UUID().uuidString
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
		case let .header(item):
			return [item]
		case let .base(_, items):
			return items
		}
	}
	
	var header: Category {
		switch self {
		case .header:
			return Category.getHeader()
		case let .base(header, _):
			return header
		}
	}
	
	init(original: CategoryMainSection, items: [CategoryMainItem]) {
		switch original {
		case let .header(item):
			self = .header(item)
		case let .base(header, items):
			self = .base(header, items)
		}
	}
}
