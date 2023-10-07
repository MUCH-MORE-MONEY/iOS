//
//  CategoryEditSectionModel.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/24.
//

import RxDataSources
import Foundation

// AnimatableSectionModel: 자동으로 셀 애니메이션 관리
typealias CategoryEditSectionModel = AnimatableSectionModel<CategoryEditSection, CategoryEditItem>

enum CategoryEditSection {
	case header(CategoryEditItem)
	case base(CategoryHeader, [CategoryEditItem])
	case footer(CategoryEditItem)
}

enum CategoryEditItem: IdentifiableType, Equatable {
	case header(CategoryEditCollectionViewCellReactor)
	case base(CategoryEditCollectionViewCellReactor)
	case footer(CategoryEditCollectionViewCellReactor)

	// IdentifiableType에 의한 identity 설정
	var identity: some Hashable {
		switch self {
		case let .header(reactor):
			return reactor.currentState.categoryEdit.orderNum
		case let .base(reactor):
			return reactor.currentState.categoryEdit.orderNum
		case let .footer(reactor):
			return reactor.currentState.categoryEdit.orderNum
		}
	}
	
	var item: CategoryEdit {
		switch self {
		case .header:
			return CategoryEdit.getDummy()
		case var .base(reactor):
			return reactor.currentState.categoryEdit
		case .footer:
			return CategoryEdit.getDummy()
		}
	}
	
	// 비교를 위한 함수
	static func == (lhs: CategoryEditItem, rhs: CategoryEditItem) -> Bool {
		lhs.identity == rhs.identity
	}
}
// MARK: - AnimatableSectionModelType Protocol
extension CategoryEditSection: AnimatableSectionModelType, Equatable {
	typealias Item = CategoryEditItem
	
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
		case let .footer(item):
			return [item]
		}
	}
	
	var header: CategoryHeader {
		switch self {
		case .header:
			return CategoryHeader.getHeader()
		case let .base(header, _):
			return header
		case .footer:
			return CategoryHeader.getFooter()
		}
	}
	
	init(original: CategoryEditSection, items: [CategoryEditItem]) {
		switch original {
		case let .header(item):
			self = .header(item)
		case let .base(header, items):
			self = .base(header, items)
		case let .footer(item):
			self = .footer(item)
		}
	}
}
