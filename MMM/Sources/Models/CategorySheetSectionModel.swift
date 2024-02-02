//
//  CategorySheetSectionModel.swift
//  MMM
//
//  Created by yuraMacBookPro on 1/22/24.
//
// 24.02.02
// 경제활동 추가/편접에서 카테고리 추가 Sheet를 Reactorkit + Rxdatasource으로 변경중 2.2버전배포로 인해야 잠깐 stop

import Foundation
import RxDataSources

typealias CategorySheetSectionModel = AnimatableSectionModel<CategorySheetSection, CategorySheetItem>

enum CategorySheetSection {
    case header(CategorySheetItem)
    case base(Category, [CategorySheetItem])
}

enum CategorySheetItem: IdentifiableType, Equatable {
    case header
    case base(CategorySheetCollectionViewCellReactor)
    
    var identity: some Hashable {
        switch self {
        case .header:
            return UUID().uuidString
            
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
    
    init(original: CategorySheetSection, items: [CategorySheetItem]) {
        switch original {
        case let .header(item):
            self = .header(item)
            
        case let .base(header, items):
            self = .base(header, items)
        }
    }
}
