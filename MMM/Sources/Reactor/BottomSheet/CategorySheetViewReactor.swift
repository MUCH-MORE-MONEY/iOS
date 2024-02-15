//
//  AddCategorySheetViewReactor.swift
//  MMM
//
//  Created by yuraMacBookPro on 1/22/24.
//

import Foundation
import ReactorKit

final class CategorySheetViewReactor: Reactor {
    enum Action {
        case loadData
        case selectCell(IndexPath, CategorySheetItem)
    }
    
    enum Mutation {
        case fetchCategoryList(CategoryListResDto)
        case setError
        case setLoading(Bool)
        case setSections([CategorySheetSectionModel])
    }
    
    struct State {
        @Pulse var categoryList: [Category] = []
        @Pulse var isLoading = true
        @Pulse var sections: [CategorySheetSectionModel] = [CategorySheetSectionModel(model: .init(original: .header(.header), items: []), items: [])]
    }
    
    var initialState: State
    
    init() {
        self.initialState = State()
    }
}

// MARK: - Mutate, Transform, Reduce
extension CategorySheetViewReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadData:
            return .concat([
                .just(.setLoading(true)),
                getCategoryList(CategoryListReqDto(dateYM: "202312", economicActivityDvcd: "01")),
                .just(.setLoading(false))
            ])
            
        case let .selectCell(indexPath, categoryItem):
            return .concat([
                .empty()
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
            
        switch mutation {
            
        case let .fetchCategoryList(response):
            let list = response.data
            newState.categoryList = list
            
        case .setError:
            newState.isLoading = false
            
        case let .setLoading(isLoading):
            newState.isLoading = isLoading
            
        case let .setSections(sections):
            newState.sections = sections
        }
        
        
        return newState
    }
}

// MARK: - Action
extension CategorySheetViewReactor {
    private func getCategoryList(_ request: CategoryListReqDto) -> Observable<Mutation> {
        return MMMAPIService().getCategoryList(request)
            .map { (response, error) -> Mutation in
                return .setSections(self.makeSections(response: response, type: "01"))
            }
            .catchAndReturn(.setError)
    }
    
    private func makeSections(response: CategoryListResDto, type: String) -> [CategorySheetSectionModel] {
        let categoryList = response.data
        var sections: [CategorySheetSectionModel] = []
        
        for category in categoryList {
            var categoryItems: [CategorySheetItem] = category.lowwer.map { categoryLowwer -> CategorySheetItem in
                return .base(.init(categoryLowwer: categoryLowwer))
            }
            
//            if categoryItems.isEmpty { categoryItems.append(.empty) }
            
            let model: CategorySheetSectionModel = .init(model: .base(category, categoryItems), items: categoryItems)
            sections.append(model)
        }
        
        return sections
    }
}
