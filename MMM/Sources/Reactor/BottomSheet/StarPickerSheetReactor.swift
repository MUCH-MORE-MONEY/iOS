//
//  StarPickerReactor.swift
//  MMM
//
//  Created by yuraMacBookPro on 1/19/24.
//

import Foundation
import RxSwift
import ReactorKit

final class StarPickerSheetReactor: Reactor {
    enum Action {
        case setStar(Int)
        case dismiss
    }
    
    enum Mutation {
        case dismiss
    }
    
    struct State {
        var dismiss: Bool = false
    }
    
    let initialState: State
    
    init(provider: ServiceProviderProtocol) {
        self.initialState = State()
    }
}

//MARK: - Mutate, Reduce
extension StarPickerSheetReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .setStar(star):
            return .empty()
            
        case .dismiss:
            return .just(.dismiss)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .dismiss:
            newState.dismiss = true
        }
        
        return newState
    }
}
