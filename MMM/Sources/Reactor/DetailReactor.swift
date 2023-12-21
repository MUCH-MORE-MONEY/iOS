//
//  DetailReactor.swift
//  MMM
//
//  Created by yuraMacBookPro on 12/21/23.
//

import Foundation
import ReactorKit

final class DetailReactor: Reactor {
    enum Action {
        case didTapEditButton
    }
    
    enum Mutation {
        case pushEditVC(Bool)
    }
    
    struct State {
        var isPushEditVC = false
    }
    
    let initialState: State
    
    init() {
        self.initialState = State()
    }
}

//MARK: - Mutate, Transform, Reduce
extension DetailReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .didTapEditButton:
            return .concat([
                .just(.pushEditVC(true)),
                .just(.pushEditVC(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .pushEditVC(isPush):
            newState.isPushEditVC = isPush
        }
        
        return newState
    }
}

// MARK: - Action
extension DetailReactor {
    
}
