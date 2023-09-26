//
//  CustomPushSettingReactor.swift
//  MMM
//
//  Created by yuraMacBookPro on 2023/09/26.
//

import Foundation
import RxSwift
import ReactorKit

final class CustomPushTextSettingReactor: Reactor {
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

extension CustomPushTextSettingReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
            
        }
        
        
        return .empty()
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
            
        }
        
        return newState
    }
}
