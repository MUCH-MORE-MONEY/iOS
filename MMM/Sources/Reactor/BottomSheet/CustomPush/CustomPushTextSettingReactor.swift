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
        case setText(String)
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

extension CustomPushTextSettingReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .setText(let text):
            return provider.profileProvider.updateCustomPushText(to: text).map { _ in .dismiss }
            
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
