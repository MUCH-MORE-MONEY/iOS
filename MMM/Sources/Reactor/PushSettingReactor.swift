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
        case eventSwitchToggle(Bool)
    }
    
    enum Mutation {
        case setPresentTimeDetail
        case setPresentTextDetail(PushResDto, Error?)
        case setEventSwitchToggle(PushAgreeUpdateResDto, Error?)
    }
    
    struct State {
        var isPresentTimeDetail = false
        var isPresentTextDetail = false
        var pushMessage: PushResDto?
        var isEventSwitchOn = false
        var pushUpdateMessage = ""
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
            
        case .eventSwitchToggle(let isOn):
            let request = PushAgreeUpdateReqDto(pushAgreeDvcd: "01", pushAgreeYN: isOn ? "Y" : "N")
            return pushAgreeUpdate(request)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        newState.isPresentTimeDetail = false
        newState.isPresentTextDetail = false
        newState.pushMessage = PushResDto(message: "")
        newState.pushUpdateMessage = ""
        
        switch mutation {
            
        case .setPresentTimeDetail:
            newState.isPresentTimeDetail = true
            
        case .setPresentTextDetail(let response, let error):
//            newState.isPresentTextDetail = true
            newState.pushMessage = response
            
        case .setEventSwitchToggle(let response, let error):
            newState.pushUpdateMessage = response.message
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
    
    func pushAgreeUpdate(_ request: PushAgreeUpdateReqDto) -> Observable<Mutation> {
        return MMMAPIService().pushAgreeUpdate(request)
            .map { (response, error) -> Mutation in
                return .setEventSwitchToggle(response, error)
            }
    }
}
