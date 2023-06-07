//
//  ProfileViewModel.swift
//  MMM
//
//  Created by geonhyeong on 2023/06/05.
//

import UIKit
import Combine

final class ProfileViewModel {
	// MARK: - Private properties
	private var cancellable: Set<AnyCancellable> = .init()
}
extension ProfileViewModel {
	/// 로그아웃 - remove Keychain
	func logout() {
		Constants.removeKeychain(forKey: Constants.KeychainKey.token)
		Constants.removeKeychain(forKey: Constants.KeychainKey.authorization)
		Constants.removeKeychain(forKey: Constants.KeychainKey.email)
	}
	
	/// 탈퇴
	func withdraw() {
		
	}
}

