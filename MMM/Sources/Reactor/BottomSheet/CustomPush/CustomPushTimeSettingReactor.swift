//
//  CustomPushTimeSettingReactor.swift
//  MMM
//
//  Created by yuraMacBookPro on 2023/09/27.
//

import Foundation
import RxSwift
import ReactorKit

final class CustomPushTimeSettingReactor: Reactor {
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        
    }
    
    let initialState: State
    let provider: ServiceProviderProtocol
    
    init(provider: ServiceProviderProtocol) {
        self.initialState = State()
        self.provider = provider
    }
}

extension CustomPushTimeSettingReactor {
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
