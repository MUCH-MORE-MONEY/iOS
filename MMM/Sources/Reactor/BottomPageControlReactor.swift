//
//  BottomPageControlReactor.swift
//  MMM
//
//  Created by yuraMacBookPro on 12/21/23.
//

import Foundation
import ReactorKit

final class BottomPageControlReactor: Reactor {
    enum Action {
        case didTapPreviousButton
        case didTapNextButton
    }
    
    enum Mutation {
        case loadData
    }
    
    struct State {
        
    }
    
    let initialState: State
    
    init() {
        self.initialState = State()
    }
}

// MARK: - Mutate, Transform, Reduce
extension BottomPageControlReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        <#code#>
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        <#code#>
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        <#code#>
    }
}

// MARK: - Action
extension BottomPageControlReactor {
    
}
