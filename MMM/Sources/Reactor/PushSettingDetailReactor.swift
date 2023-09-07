//
//  PushSettingDetailReactor.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/09/07.
//

import Foundation
import ReactorKit
import RxSwift

final class PushSettingDetailReactor: Reactor {
    enum Action {
        case didTapDetailTimeSettingView
    }
    
    enum Mutation {
        case setPresentTime(Bool)
    }
    
    struct State {
        var isPresentTime = false
    }
    
    let initialState: State
    
    init() {
        initialState = State()
    }
}

extension PushSettingDetailReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .didTapDetailTimeSettingView:
            return Observable.concat([
                .just(.setPresentTime(true)),
                .just(.setPresentTime(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
            
        case .setPresentTime(let isPresent):
            newState.isPresentTime = isPresent
        }
        
        return newState
    }
}
