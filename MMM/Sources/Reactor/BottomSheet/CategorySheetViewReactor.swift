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
    }
    
    enum Mutation {
        case fetchCategoryList(CategoryListResDto)
        case setError
        case setLoading(Bool)
    }
    
    struct State {
        @Pulse var categoryList: [Category] = []
        @Pulse var isLoading = true
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
        }
        
        return newState
    }
}

// MARK: - Action
extension CategorySheetViewReactor {
    func getCategoryList(_ request: CategoryListReqDto) -> Observable<Mutation> {
        return MMMAPIService().getCategoryList(request)
            .map { (response, error) -> Mutation in
                return .fetchCategoryList(response)
            }
            .catchAndReturn(.setError)
    }
}
