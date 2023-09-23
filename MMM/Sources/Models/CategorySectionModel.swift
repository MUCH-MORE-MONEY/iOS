//
//  CategorySectionModel.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/16.
//

import RxDataSources
import Foundation

// AnimatableSectionModel: 자동으로 셀 애니메이션 관리
typealias CategorySectionModel = AnimatableSectionModel<CategorySection, CategoryItem>

enum CategorySection {
	case base(CategoryHeader, [CategoryItem])
}

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
// MARK: - AnimatableSectionModelType Protocol
extension CategorySection: AnimatableSectionModelType {
	typealias Item = CategoryItem
	
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
	
	init(original: CategorySection, items: [CategoryItem]) {
		switch original {
		case .base(let header, let items):
			self = .base(header, items)
		}
	}
}
