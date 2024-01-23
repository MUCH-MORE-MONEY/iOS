//
//  CategorySheetSectionModel.swift
//  MMM
//
//  Created by yuraMacBookPro on 1/22/24.
//

import Foundation
import RxDataSources

typealias CategorySheetSectionModel = AnimatableSectionModel<CategorySheetSection, CategorySheetItem>

enum CategorySheetSection {
    case base(Category, [CategorySheetItem])
}

enum CategorySheetItem: IdentifiableType, Equatable {
    case base(CategorySheetCollectionViewCellReactor)
    
    var identity: some Hashable {
        switch self {
    
        case let .base(reactor):
            return reactor.currentState.categoryLowwer.id
        }
    }
    
    static func == (lhs: CategorySheetItem, rhs: CategorySheetItem) -> Bool {
        lhs.identity == rhs.identity
    }
}

// MARK: - AnimatableSectionModelType Protocol
extension CategorySheetSection: AnimatableSectionModelType {
    typealias Item = CategorySheetItem
    
    var identity: String {
        return "\(items.count)"
    }
    
    var items: [Item] {
        switch self {
        case let .base(_, items):
            return items
        }
    }
    
    var header: Category {
        switch self {
        case let .base(header, _):
            return header
        }
    }
    
    init(original: CategorySheetSection, items: [CategorySheetItem]) {
        switch original {
        case let .base(header, items):
            self = .base(header, items)
        }
    }
}
