//
//  AddCategorySheetViewReactor.swift
//  MMM
//
//  Created by yuraMacBookPro on 1/22/24.
//

import Foundation
import ReactorKit

final class AddCategorySheetViewReactor: Reactor {
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        
    }
    
    var initialState: State
    
    init() {
        self.initialState = State()
    }
}

// MARK: - Mutate, Transform, Reduce
extension AddCategorySheetViewReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        default:
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
            
        }
        
        return newState
    }
}

// MARK: - Action
extension AddCategorySheetViewReactor {
    
}
