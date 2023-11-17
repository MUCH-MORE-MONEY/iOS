//
//  PushSettingDetailReactor.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/09/07.
//

import Foundation
import ReactorKit
import RxSwift
import UserNotifications

final class PushSettingDetailReactor: Reactor {
    enum Action {
        case didTapDetailTimeSettingView
        case viewAppear(String)
        case viewWillDisappear
        case checkPushTime
    }
    
    enum Mutation {
        case setTime(String)
		case setDate(Date)
        case setPresentTime(Bool)
        case viewWillDisappear
        case setPushTime(String)
    }
    
    struct State {
        var isViewAppear = false
        var time = ""
		var date = Date()
        var isPresentTime = false
        var pushTime = ""
    }
    
    let initialState: State
	let provider: ServiceProviderProtocol

    init(provider: ServiceProviderProtocol) {
		self.initialState = State()
		self.provider = provider
    }
}

extension PushSettingDetailReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
            
        case .viewAppear(let time):
            return Observable.just(.setTime(time))
            
        case .didTapDetailTimeSettingView:
            return Observable.concat([
                .just(.setPresentTime(true)),
                .just(.setPresentTime(false))
            ])
            
        case .viewWillDisappear:
            let notificationCenter = UNUserNotificationCenter.current()
            
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
            
            return .just(.viewWillDisappear)
            
        case .checkPushTime:
            let value = Common.getCustomPushTime()
            return .just(.setPushTime(value))
        }
    }
	
	/// 각각의 stream을 변형
	func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
		let tagEvent = provider.profileProvider.event.flatMap { event -> Observable<Mutation> in
			switch event {
			case .updateDate(let date):
                let dateString = date.getFormattedTime()
                Common.setCustomPushTime(dateString)    // Picker에서 값을 확인을 누르게 되면 UserDefault에 저장
				return .just(.setDate(date))
            default:
                return .empty()
			}
		}
		
		return Observable.merge(mutation, tagEvent)
	}
	
    
	func reduce(state: State, mutation: Mutation) -> State {
		var newState = state
		
        newState.isViewAppear = false
        
		switch mutation {
            
        case .setTime(let time):
            newState.time = time
            newState.isViewAppear = true
            
		case .setDate(let date):
			newState.date = date
            
		case .setPresentTime(let isPresent):
			newState.isPresentTime = isPresent
        case .viewWillDisappear:
            print("viewWillAppear")
            
        case .setPushTime(let time):
            newState.pushTime = time
            
        }
        return newState
    }
}

// MARK: - Actions
extension PushSettingDetailReactor {
    func scheduleWeeklyNotification(day: Int, time: String) {
        // 알림 내용 설정
        let notificationCenter = UNUserNotificationCenter.current()
                
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
