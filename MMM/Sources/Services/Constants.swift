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
        case accessToken
        case authorization
        case email
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

    /**
     # getKeychainValue
     - parameters:
        - keychainKey : 반환할 value의 Key - (E) Common.KeychainKey
     - Note: 키체인 값을 반환하는 공용 함수
     */
    static func getKeychainValue(forKey keychainKey: KeychainKey) -> String? {
        return KeychainWrapper.standard.string(forKey: keychainKey.rawValue)
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
}
