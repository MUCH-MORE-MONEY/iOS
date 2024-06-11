//
//  KeyChain.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/04/27.
//

import Foundation
import SwiftKeychainWrapper

// MARK: - KeyChain 저장을 위한 클래스
final class Constants {
    /**
     # (E) KeychainKey
     */
    enum KeychainKey: String {
        case token
        case authorization
        case email
        case pushToken
		case isHighlight
		case isDailySetting
		case earnStandard // 수입
		case payStandard // 지출
		case statisticsDate // 현재 통계 날짜
		case isInit // 첫 진입인지
		case isHomeLoading // 탭 이동을 통한 Home 접근인지
		case onBoardingFlag // 홈에서 온보딩 팝업 여부
    }
    
    /**
     # setKeychain
     - parameters:
        - value : 저장할 값
        - keychainKey : 저장할 value의  Key - (E) Common.KeychainKey
     - Note: 키체인에 값을 저장하는 공용 함수
     */
    static func setKeychain(_ value: String, forKey keychainKey: KeychainKey) {
        KeychainWrapper.standard.set(value, forKey: keychainKey.rawValue)
    }
	
	static func setKeychain(_ value: Int, forKey keychainKey: KeychainKey) {
		KeychainWrapper.standard.set(value, forKey: keychainKey.rawValue)
	}
	
	static func setKeychain(_ value: Bool, forKey keychainKey: KeychainKey) {
		KeychainWrapper.standard.set(value, forKey: keychainKey.rawValue)
	}

    /**
     # getKeychainValue
     - parameters:
        - keychainKey : 반환할 value의 Key - (E) Common.KeychainKey
     - Note: 키체인 값을 반환하는 공용 함수
     */
    static func getKeychainValue(forKey keychainKey: KeychainKey) -> String? {
        return KeychainWrapper.standard.string(forKey: keychainKey.rawValue)
    }
	
	static func getKeychainValueByInt(forKey keychainKey: KeychainKey) -> Int? {
		return KeychainWrapper.standard.integer(forKey: keychainKey.rawValue)
	}
	
	static func getKeychainValueByBool(forKey keychainKey: KeychainKey) -> Bool? {
		return KeychainWrapper.standard.bool(forKey: keychainKey.rawValue)
	}
    
    /**
     # removeKeychain
     - parameters:
        - keychainKey : 삭제할 value의  Key - (E) Common.KeychainKey
     - Note: 키체인 값을 삭제하는 공용 함수
     */
    static func removeKeychain(forKey keychainKey: KeychainKey) {
        KeychainWrapper.standard.removeObject(forKey: keychainKey.rawValue)
    }
	
	/// 사용자의 모든 정보를 제거
	static func removeAllKeychain() {
		Constants.removeKeychain(forKey: Constants.KeychainKey.token)
		Constants.removeKeychain(forKey: Constants.KeychainKey.authorization)
		Constants.removeKeychain(forKey: Constants.KeychainKey.email)
		Constants.removeKeychain(forKey: Constants.KeychainKey.isHighlight)
		Constants.removeKeychain(forKey: Constants.KeychainKey.isDailySetting)
		Constants.removeKeychain(forKey: Constants.KeychainKey.earnStandard)
		Constants.removeKeychain(forKey: Constants.KeychainKey.payStandard)
        Constants.removeKeychain(forKey: Constants.KeychainKey.pushToken)
	}
}

// TODO: - 데이터 삭제 함수 필요
enum Common {
    
    enum keys: String {
        case newsPushSwitch
        case customPushSwitch
        case customPushTime
        case customPushDate
        case customPushText
        case customPushWeekList
        case customPushNudge
        case saveButtonTapped
        case nudgeIfPushRestricted
        case calendarSelectedDate
        case deferredVersion
    }
    
    
    // MARK: - Set
    static func setNewsPushSwitch(_ isOn: Bool) {
        UserDefaults.standard.set(isOn, forKey: self.keys.newsPushSwitch.rawValue)
    }
    
    static func setCustomPushSwitch(_ isOn: Bool) {
        UserDefaults.standard.set(isOn, forKey: self.keys.customPushSwitch.rawValue)
    }
    
    // 최초 앱 설치 시 저장
    static func setCustomPushTime(_ date: String) {
        UserDefaults.standard.set(date, forKey: self.keys.customPushTime.rawValue)
    }
    
    // 시간 요일에 따른 저장
    static func setCustomPushTime(_ days: [Bool]) {
        
        print("userDefaults : \(days)")
        var title = ""
        if days.filter({ $0 }).count == 7 {
            title += "매일"
        } else {
            for (index, isOn) in days.enumerated() {
                if isOn {
                    switch index {
                    case 0:
                        title += "일 ,"
                    case 1:
                        title += "월 ,"
                    case 3:
                        title += "화 ,"
                    case 4:
                        title += "수 ,"
                    case 5:
                        title += "목 ,"
                    case 6:
                        title += "금 ,"
                    case 7:
                        title += "토 ,"
                    default:
                        break
                    }
                }
            }
        }

        if title.last == "," {
            title.removeLast()
        }
        
        UserDefaults.standard.set(title, forKey: self.keys.customPushTime.rawValue)
    }
    
    static func setCustomPushText(_ text: String) {
        UserDefaults.standard.set(text, forKey: self.keys.customPushText.rawValue)
    }
    
    static func setCustomPushWeekList(_ list: [Bool]) {
        UserDefaults.standard.setValue(list, forKey: self.keys.customPushWeekList.rawValue)
    }
    
    static func setCustomPusDate(_ date: Date) {
        UserDefaults.standard.setValue(date, forKey: self.keys.customPushDate.rawValue)
    }
    
    static func setCustomPushNudge(_ isFirst: Bool) {
        UserDefaults.standard.setValue(isFirst, forKey: self.keys.customPushNudge.rawValue)
    }
    
    static func setSaveButtonTapped(_ isFirst: Bool) {
        UserDefaults.standard.setValue(isFirst, forKey: self.keys.saveButtonTapped.rawValue)
    }
    
    static func setNudgeIfPushRestricted(_ isRestricted: Bool) {
        UserDefaults.standard.setValue(isRestricted, forKey: self.keys.nudgeIfPushRestricted.rawValue)
    }
    
    static func setCalendarSelectedDate(_ date: Date) {
        UserDefaults.standard.setValue(date, forKey: self.keys.calendarSelectedDate.rawValue)
    }
    
    static func setDeferredVersion(_ version: String) {
        UserDefaults.standard.set(version, forKey: self.keys.deferredVersion.rawValue)
    }
    
    // MARK: - Get
    static func getNewsPushSwitch() -> Bool {
        UserDefaults.standard.bool(forKey: self.keys.newsPushSwitch.rawValue)
    }
    
    static func getCustomPushSwitch() -> Bool {
        UserDefaults.standard.bool(forKey: self.keys.customPushSwitch.rawValue)
    }
    
    static func getCustomPushTime() -> String {
        UserDefaults.standard.string(forKey: self.keys.customPushTime.rawValue) ?? "09:00 PM"
    }
    
    static func getCustomPushText() -> String {
        UserDefaults.standard.string(forKey: self.keys.customPushText.rawValue) ?? "💸 오늘은 어떤 경제활동을 했나요?"
    }
    
    static func getCustomPushWeekList() -> [Bool] {
        // UserDefaults에서 상태 불러오기
        var selectedDays: [Bool] = []
        
        if let savedDays = UserDefaults.standard.array(forKey: self.keys.customPushWeekList.rawValue) as? [Bool], savedDays.count == 7 {
            selectedDays = savedDays
        } else {
            return Array(repeating: true, count: 7)
        }
        
        return selectedDays
    }
    
    static func getCustomPushDate() -> Date {
        let now = Date()
        
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: now)
        
        dateComponents.hour = 21
        dateComponents.minute = 0
        
        guard let defaultDate = calendar.date(from: dateComponents) else { return Date() }
        
        return UserDefaults.standard.object(forKey: self.keys.customPushDate.rawValue) as? Date ?? defaultDate
    }
    
    static func getCustomPuhsNudge() -> Bool {
        return UserDefaults.standard.bool(forKey: self.keys.customPushNudge.rawValue)
    }
    
    static func getSaveButtonTapped() -> Bool {
        return UserDefaults.standard.bool(forKey: self.keys.saveButtonTapped.rawValue)
    }
    
    static func getNudgeIfPushRestricted() -> Bool {
        return UserDefaults.standard.bool(forKey: self.keys.nudgeIfPushRestricted.rawValue)
    }
    
    static func getCalendarSelectedDate() -> Date {
        return UserDefaults.standard.object(forKey: self.keys.calendarSelectedDate.rawValue) as? Date ?? Date()
    }
    
    static func getDefferedVersion() -> String {
        return UserDefaults.standard.string(forKey: self.keys.deferredVersion.rawValue) ?? "0.0.0"
    }
}
