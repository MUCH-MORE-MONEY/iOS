//
//  PushSettingReactor.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/08/24.
//

import Foundation
import ReactorKit

final class PushSettingReactor: Reactor {
    enum Action {
        case didTapTimeSettingButton
        case didTapTextSettingButton
    }
    
    enum Mutation {
        case setPresentTimeDetail
        case setPresentTextDetail
    }
    
    struct State {
        var isPresentTimeDetail = false
        var isPresentTextDetail = false
    }
    
    let initialState: State
    
    init() { initialState = State() }
}

extension PushSettingReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
            
        case .didTapTimeSettingButton:
            return .just(.setPresentTimeDetail)
        case .didTapTextSettingButton:
            return .just(.setPresentTextDetail)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        newState.isPresentTimeDetail = false
        newState.isPresentTextDetail = false
        
        switch mutation {
            
        case .setPresentTimeDetail:
            newState.isPresentTimeDetail = true
            
        case .setPresentTextDetail:
            newState.isPresentTimeDetail = true
        }
        
        return newState
    }
}
