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
        case viewAppear
    }
    
    enum Mutation {
        case getSwitchState(PushAgreeListSelectResDto, Error?)
        case setPresentTimeDetail
        case setPresentTextDetail(PushResDto, Error?)
        case updatePushAgreeSwitch(PushAgreeUpdateResDto, Error?)
    }
    
    struct State {
        var isInit = false
        var isPresentTimeDetail = false
        var isPresentTextDetail = false
        var pushMessage: PushResDto?
        var isEventSwitchOn = false
        var pushList: [PushAgreeListSelectResDto.SelectedList] = []
    }
        
    let initialState: State
    
    init() {
        initialState = State()
    }
}

extension PushSettingReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewAppear:
            return pushAgreeListSelect()
            
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
        newState.pushList = []
        
        switch mutation {
        
        case .getSwitchState(let response, let error):
            newState.pushList = response.selectedList
            newState.isInit = true
            
        case .setPresentTimeDetail:
            newState.isPresentTimeDetail = true
            
        case .setPresentTextDetail(let response, let error):
//            newState.isPresentTextDetail = true
            newState.pushMessage = response
            
        case .updatePushAgreeSwitch(let response, let error):
            newState.isEventSwitchOn.toggle()
        }
        
        return newState
    }
}

// MARK: - Actions
extension PushSettingReactor {
    func pushAgreeListSelect() -> Observable<Mutation> {
        return MMMAPIService().pushAgreeListSelect()
            .map { (response, error) -> Mutation in
                return .getSwitchState(response, error)
            }
    }
    
    func push(_ request: PushReqDto) -> Observable<Mutation>{
        return MMMAPIService().push(request)
            .map { (response, error) -> Mutation in
                return .setPresentTextDetail(response, error)
            }
    }
    
    func pushAgreeUpdate(_ request: PushAgreeUpdateReqDto) -> Observable<Mutation> {
        return MMMAPIService().pushAgreeUpdate(request)
            .map { (response, error) -> Mutation in
                return .updatePushAgreeSwitch(response, error)
            }
    }
}
