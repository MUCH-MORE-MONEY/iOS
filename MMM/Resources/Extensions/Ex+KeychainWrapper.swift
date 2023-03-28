//
//  Ex+KeychainWrapper.swift
//  MMM
//
//  Created by geonhyeong on 2023/03/27.
//  Copyright © 2023 Lab.M. All rights reserved.
//

import SwiftKeychainWrapper

extension KeychainWrapper.Key {
	static let id: KeychainWrapper.Key = "id"
	static let accessToken: KeychainWrapper.Key = "accessToken"
	static let refreshToken: KeychainWrapper.Key = "refreshToken"
}

// 사용법
// 참고: https://github.com/jrendel/SwiftKeychainWrapper
// Access: KeychainWrapper.standard[.accessToken]!
// Write: KeychainWrapper.standard[.accessToken] = accessToken
// Delete: KeychainWrapper.standard.removeObject(forKey: KeychainWrapper.Key.accessToken.rawValue)
