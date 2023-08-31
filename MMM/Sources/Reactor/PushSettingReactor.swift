//
//  PushSettingReactor.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/08/24.
//

import Foundation
import ReactorKit
import Moya

final class PushSettingReactor: Reactor {
    enum Action {
        case didTapTimeSettingButton
        case didTapTextSettingButton(PushReqDto)
    }
    
    enum Mutation {
        case setPresentTimeDetail
        case setPresentTextDetail(PushResDto, Error?)
    }
    
    struct State {
        var isPresentTimeDetail = false
        var isPresentTextDetail = false
        var pushMessage: PushResDto?
    }
        
    let initialState: State
    
    init() {
        initialState = State()
    }
}

extension PushSettingReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
            
        case .didTapTimeSettingButton:
            return .just(.setPresentTimeDetail)
            
        case .didTapTextSettingButton(let request):
            return push(request)
            
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        newState.isPresentTimeDetail = false
        newState.isPresentTextDetail = false
        newState.pushMessage = PushResDto(message: "")
        
        switch mutation {
            
        case .setPresentTimeDetail:
            newState.isPresentTimeDetail = true
            
        case .setPresentTextDetail(let response, _):
//            newState.isPresentTextDetail = true
            newState.pushMessage = response
            
        }
        
        return newState
    }
}

// MARK: - Actions
extension PushSettingReactor {
    func push(_ request: PushReqDto) -> Observable<Mutation>{
        return MMMAPIService().push(request)
            .map { (response, error) -> Mutation in
                return .setPresentTextDetail(response, error)
            }
    }
}
