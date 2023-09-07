//
//  PushSettingReactor.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/08/24.
//

import Foundation
import ReactorKit
import Moya
import UserNotifications

final class PushSettingReactor: Reactor {
    enum Action {
        case viewAppear
        case didTapTimeSettingButton
        case didTapTextSettingButton(PushReqDto)
        case eventSwitchToggle(Bool)
        case infoSwitchToggle(Bool)
    }
    
    enum Mutation {
        case pushSettingAvailable(Bool)
        case getSwitchState(PushAgreeListSelectResDto, Error?)
        case setPresentTimeDetail
        case setPresentTextDetail(PushResDto, Error?)
        case updatePushAgreeSwitch(PushAgreeUpdateResDto, Error?)
        case setInfoSwitch(Bool)
    }
    
    struct State {
        var isInit = false
        var isShowPushAlert = true
        var isPresentTimeDetail = false
        var isPresentTextDetail = false
        var pushMessage: PushResDto?
        var isEventSwitchOn = false
        var isInfoSwitchOn = false
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
            // FIXME: - 권한 요청 시 화면 로딩이 늦는 문제
        case .viewAppear:
            return Observable.create { observer in
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    switch settings.authorizationStatus {
                    case .authorized:
                        observer.onNext(.pushSettingAvailable(true))
                    default:
                        observer.onNext(.pushSettingAvailable(false))
                    }
                }
                return Disposables.create()
            }
            
        case .didTapTimeSettingButton:
            return .just(.setPresentTimeDetail)
            
        case .didTapTextSettingButton(let request):
            return push(request)
            
        case .eventSwitchToggle(let isOn):
            let request = PushAgreeUpdateReqDto(pushAgreeDvcd: "01", pushAgreeYN: isOn ? "Y" : "N")
            return pushAgreeUpdate(request)
            
        case .infoSwitchToggle(let isOn):
            return .just(.setInfoSwitch(isOn))
        }
        
        
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        newState.isPresentTimeDetail = false
        newState.isPresentTextDetail = false
        newState.pushMessage = PushResDto(message: "")
        newState.pushList = []
        
        switch mutation {
        case .pushSettingAvailable(let isOn):
            print("isOn : \(isOn)")
            newState.isShowPushAlert = isOn
            
        case .getSwitchState(let response, let error):
            newState.pushList = response.selectedList
            
        case .setPresentTimeDetail:
            newState.isPresentTimeDetail = true
            
        case .setPresentTextDetail(let response, let error):
            //            newState.isPresentTextDetail = true
            newState.pushMessage = response
            
        case .updatePushAgreeSwitch(let response, let error):
            newState.isEventSwitchOn.toggle()
            
        case .setInfoSwitch(let isOn):
            newState.isInfoSwitchOn = isOn
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
    
    //    func checkPushSetting() -> Observable<Mutation> {
    //        var isOn = false
    //        UNUserNotificationCenter.current().getNotificationSettings { settings in
    //            switch settings.authorizationStatus {
    //            case .authorized:
    //                print("허용")
    //                isOn = true
    //            case .denied:
    //                print("거부")
    //                isOn = false
    //            case .notDetermined:
    //                print("설정 전임")
    //            default:
    //                break
    //            }
    //
    //            return .just(.pushSettingAvailable(isOn))
    //        }
    //    }
}
