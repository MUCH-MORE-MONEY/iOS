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
        case setDate(Date)
        case dismiss
    }
    
    enum Mutation {
        case dismiss
    }
    
    struct State {
        var dismiss: Bool = false
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
            
        case.setDate(let date):
            return provider.profileProvider.updateDate(to: date).map { _ in .dismiss}
            
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
