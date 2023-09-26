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
        case didTapCustomPushTimeSettingView
//        case didTapTextSettingButton(PushReqDto)
        case didTapCustomPushTextSettingView
        case newsPushSwitchToggle(Bool)
        case customPushSwitchToggle(Bool)
    }
    
    enum Mutation {
        case pushSettingAvailable(Bool)
        
        case setPresentDetailView(Bool)
        case setPresentSheetView(Bool)  // 맞춤 알림 시트
        
        //        case setPresentTextDetail(PushResDto, Error?)
        case updatePushAgreeSwitch(PushAgreeUpdateResDto, Error?)
        
        case setNewsPushSwitch(Bool)
        case setCustomPushSwitch(Bool)
        
        case setCustomPushText(String)
        
    }
    
    struct State {
        var isShowPushAlert = true
        var isPresentDetailView = false
        var isPresentSheetView = false
        var pushMessage: PushResDto?
        var isNewsPushSwitchOn = false
        var isCustomPushSwitchOn = false
        var pushList: [PushAgreeListSelectResDto.SelectedList] = []
        var customPushLabelText: String = ""
    }
    
    let initialState: State
    let provider: ServiceProviderProtocol
    
    init(provider: ServiceProviderProtocol) {
        self.initialState = State()
        self.provider = provider
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
            
        case .didTapCustomPushTimeSettingView:
            return Observable.concat([
                .just(.setPresentDetailView(true)),
                .just(.setPresentDetailView(false))])
            
        case .didTapCustomPushTextSettingView:
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
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let event = provider.profileProvider.event.flatMap { event ->
            Observable<Mutation> in
            switch event {
            case .updateCustomPushText(let text):
                return .just(.setCustomPushText(text))
            default:
                return .empty()
            }
        }
        
        return Observable.merge(mutation, event)
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        newState.pushMessage = PushResDto(message: "")
        newState.pushList = []
        
        switch mutation {
        case .pushSettingAvailable(let isOn):
            newState.isShowPushAlert = isOn
            
            if !isOn {
                newState.isNewsPushSwitchOn = false
                newState.isCustomPushSwitchOn = false
                Common.setNewsPushSwitch(false)
                Common.setCustomPushSwitch(false)
            }
            
        case .updatePushAgreeSwitch(let response, let error):
            newState.isNewsPushSwitchOn.toggle()

        // MARK: - 여긴 완성
        case .setPresentDetailView(let isPresent):
            newState.isPresentDetailView = isPresent
            
        case .setPresentSheetView(let isPresent):
            newState.isPresentSheetView = isPresent
            
        case .setNewsPushSwitch(let isOn):
            newState.isNewsPushSwitchOn = isOn
            
        case .setCustomPushSwitch(let isOn):
            newState.isCustomPushSwitchOn = isOn
            
        case .setCustomPushText(let text):
            newState.customPushLabelText = text
        }

        return newState
    }
}

// MARK: - Actions
extension PushSettingReactor {
    
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
