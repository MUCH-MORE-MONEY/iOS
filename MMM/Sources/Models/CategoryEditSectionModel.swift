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
	case base(CategoryHeader, [CategoryEditItem])
}

enum CategoryEditItem: IdentifiableType, Equatable {
	case base(CategoryEditCollectionViewCellReactor)
	
	// IdentifiableType에 의한 identity 설정
	var identity: some Hashable {
		switch self {
		case let .base(reactor):
			return reactor.currentState.categoryEdit.orderNum
		}
	}
	
	var item: CategoryEdit {
		switch self {
		case var .base(reactor):
			return reactor.currentState.categoryEdit
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
		case .base(_, let items):
			return items
		}
	}
	
	var header: CategoryHeader {
		switch self {
		case .base(let header, _):
			return header
		}
	}
	
	init(original: CategoryEditSection, items: [CategoryEditItem]) {
		switch original {
		case .base(let header, let items):
			self = .base(header, items)
		}
	}
}
