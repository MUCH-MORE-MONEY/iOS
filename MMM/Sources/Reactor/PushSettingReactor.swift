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
        //        case didTapTextSettingButton(PushReqDto)
        case didTapTextSettingButton
        case newsPushSwitchToggle(Bool)
        case customPushSwitchToggle(Bool)
    }
    
    enum Mutation {
        case pushSettingAvailable(Bool)
        
        case setPresentDetailView(Bool)
        case setPresentSheetView(Bool)
        
        //        case setPresentTextDetail(PushResDto, Error?)
        case updatePushAgreeSwitch(PushAgreeUpdateResDto, Error?)
        case getSwitchState(PushAgreeListSelectResDto, Error?)
        
        case setNewsPushSwitch(Bool)
        case setCustomPushSwitch(Bool)
        
    }
    
    struct State {
        var isShowPushAlert = true
        var isPresentDetailView = false
        var isPresentSheetView = false
        var pushMessage: PushResDto?
        var isNewsPushSwitchOn = false
        var isCustomPushSwitchOn = false
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
            return Observable.concat([
                .just(.setPresentDetailView(true)),
                .just(.setPresentDetailView(false))])
            
            //        case .didTapTextSettingButton(let request):
            //            return push(request)
        case .didTapTextSettingButton:
            return Observable.concat([
                .just(.setPresentSheetView(true)),
                .just(.setPresentSheetView(false))])
            //        case .newsPushSwitchToggle(let isOn):
            //            let request = PushAgreeUpdateReqDto(pushAgreeDvcd: "01", pushAgreeYN: isOn ? "Y" : "N")
            //            return pushAgreeUpdate(request)
        case .newsPushSwitchToggle(let isOn):
            return .just(.setNewsPushSwitch(isOn))
            
        case .customPushSwitchToggle(let isOn):
            return .just(.setCustomPushSwitch(isOn))
        }
        
        
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        newState.pushMessage = PushResDto(message: "")
        newState.pushList = []
        
        switch mutation {
        case .pushSettingAvailable(let isOn):
            print("isOn : \(isOn)")
            newState.isShowPushAlert = isOn
            
        case .getSwitchState(let response, let error):
            newState.pushList = response.selectedList
            

            
            //        case .setPresentTextDetail(let response, let error):
            //            //            newState.isPresentTextDetail = true
            //            newState.pushMessage = response
            
        case .updatePushAgreeSwitch(let response, let error):
            newState.isNewsPushSwitchOn.toggle()

        // MARK: - 여긴 완성
        case .setPresentDetailView(let isPresent):
            newState.isPresentDetailView = isPresent
            
        case .setPresentSheetView(let isPresent):
            newState.isPresentSheetView = isPresent
            
        case .setNewsPushSwitch(let isOn):
            newState.isNewsPushSwitchOn = isOn
            Common.setNewsPushSwitch(isOn)
            
        case .setCustomPushSwitch(let isOn):
            newState.isCustomPushSwitchOn = isOn
            Common.setCustomPushSwitch(isOn)
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
    
    //    func push(_ request: PushReqDto) -> Observable<Mutation>{
    //        return MMMAPIService().push(request)
    //            .map { (response, error) -> Mutation in
    //                return .setPresentTextDetail(response, error)
    //            }
    //    }
    
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
