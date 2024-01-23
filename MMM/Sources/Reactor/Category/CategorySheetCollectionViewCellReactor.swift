//
//  CategorySheetCollectionViewCellReactor.swift
//  MMM
//
//  Created by yuraMacBookPro on 1/23/24.
//

import Foundation
import ReactorKit

final class CategorySheetCollectionViewCellReactor: Reactor {
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        let categoryLowwer: CategoryLowwer
    }
    
    let initialState: State
    
    init(categoryLowwer: CategoryLowwer) {
        initialState = .init(categoryLowwer: categoryLowwer)
    }
}

// MARK: - Mutate, Reduce
extension CategorySheetCollectionViewCellReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        let newState = state
        
        switch mutation {
            
        }
        
        return newState
    }
}

