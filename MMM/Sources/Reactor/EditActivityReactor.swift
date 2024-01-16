//
//  EditActivityReactor.swift
//  MMM
//
//  Created by yuraMacBookPro on 1/9/24.
//

import Foundation
import ReactorKit

final class EditActivityReactor: Reactor {
    enum Action {
        case didTapEditButton
        case loadData
    }
    
    enum Mutation {
        case setData(SelectDetailResDto)
        case setLoading(Bool)
    }
    
    struct State {
        @Pulse var isLoading = true
        @Pulse var activity: SelectDetailResDto?
    }
    
    var initialState: State
    
    init(activity: SelectDetailResDto) {
        self.initialState = State(activity: activity)
    }
}

// MARK: - Mutate, Transform, Reduce
extension EditActivityReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadData:
            guard let activity = self.currentState.activity else { return .empty() }
            return .just(.setData(activity))
            
        case .didTapEditButton:
            return .concat([
                .just(.setLoading(true)),
                .just(.setLoading(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .setData(activity):
            print(activity)
            newState.activity = activity
            
        case let .setLoading(isLoading):
            newState.isLoading = isLoading
        }
        
        return newState
    }
}

// MARK: - Action
extension EditActivityReactor {
    
}
