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
        case didTapCheckButton(String)
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
        case .didTapCheckButton(let text):
            
            let notificationCenter = UNUserNotificationCenter.current()
            // checkbutton을 누르면 기존에 있던 걸 다 지워주고 다시 noti 등록
            notificationCenter.removeAllPendingNotificationRequests()
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

// MARK: - Actions
extension CustomPushTextSettingReactor {
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
            }
        }
    }
}
