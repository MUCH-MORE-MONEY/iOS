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
            let request = PushAgreeUpdateReqDto(pushAgreeDvcd: "01", pushAgreeYN: isOn ? "Y" : "N")
            return Observable.concat([
                .just(.setNewsPushSwitch(isOn)),
                pushAgreeUpdate(request)])
            
        case .customPushSwitchToggle(let isOn):
            let notificationCenter = UNUserNotificationCenter.current()
            
            if isOn {
                notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if granted {
                        print("알림 허용")
                        
                        let time = Common.getCustomPushTime()
                        let weekList = Common.getCustomPushWeekList()
                        for (day, isOn) in weekList.enumerated() {
                            if isOn {
                                // 특정 요일 선택 (1은 일요일, 2는 월요일, ..., 7은 토요일)
                                self.scheduleWeeklyNotification(day: day+1, time: time)
                            }
                        }
                    } else {
                        print("알림 거부")
                    }
                }
            } else {
                notificationCenter.removeAllPendingNotificationRequests()
            }
            
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
            print(response)

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
            Common.setCustomPushText(text)
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
        
    func scheduleWeeklyNotification(day: Int, time: String) {
        // 알림 내용 설정
        let notificationCenter = UNUserNotificationCenter.current()
        
//        notificationCenter.removeAllPendingNotificationRequests()
        
        let hour = time.components(separatedBy: ":")[0]
        let minute = time
            .components(separatedBy: ":")[1]
            .components(separatedBy: " ")[0]
        
        let content = UNMutableNotificationContent()
        content.title = "MMM"
        content.body = Common.getCustomPushText()
        
        // 알림 발생 시간 설정
        var dateComponents = DateComponents()
        
        dateComponents.hour = Int(hour)! // 알림을 원하는 시간으로 변경
        dateComponents.minute = Int(minute)!

        dateComponents.weekday = day // 특정 요일 선택 (1은 일요일, 2는 월요일, ..., 7은 토요일)
        // 알림 요청 생성
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: "weeklyNoti\(day)", content: content, trigger: trigger)

        // 알림 요청 등록
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("알림 등록 중 오류 발생: \(error.localizedDescription)")
            } else {
                print("알림이 성공적으로 등록되었습니다.")
                UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                    for request in requests {
                        print("예약된 알림: \(request.identifier)")
                    }
                }
            }
        }
    }
}
