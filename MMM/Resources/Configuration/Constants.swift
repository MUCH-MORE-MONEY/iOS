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
        case customPushText
    }
    
    // MARK: - Set
    static func setNewsPushSwitch(_ isOn: Bool) {
        UserDefaults.standard.set(isOn, forKey: self.keys.newsPushSwitch.rawValue)
    }
    
    static func setCustomPushSwitch(_ isOn: Bool) {
        UserDefaults.standard.set(isOn, forKey: self.keys.customPushSwitch.rawValue)
    }
    
    static func setCustomPushTime(_ date: String) {
        UserDefaults.standard.set(date, forKey: self.keys.customPushTime.rawValue)
    }
    
    static func setCustomPushText(_ text: String) {
        UserDefaults.standard.set(text, forKey: self.keys.customPushText.rawValue)
    }
    
    // MARK: - Get
    static func getNewsPushSwitch() -> Bool {
        UserDefaults.standard.bool(forKey: self.keys.newsPushSwitch.rawValue)
    }
    
    static func getCustomPushSwitch() -> Bool {
        UserDefaults.standard.bool(forKey: self.keys.customPushSwitch.rawValue)
    }
    
    static func getCustomPushTime() -> String {
        UserDefaults.standard.string(forKey: self.keys.customPushTime.rawValue) ?? "매일 09:00 PM"
    }
    
    static func getCustomPushText() -> String {
        UserDefaults.standard.string(forKey: self.keys.customPushText.rawValue) ?? "💸 오늘은 어떤 경제활동을 했나요?"
    }
}
