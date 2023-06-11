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
	@Published var summary: (recordCnt: Int?, recordSumAmount: Int?)
	
	private var cancellable: Set<AnyCancellable> = .init()
}
extension ProfileViewModel {
	/// 경제활동 요약
	func getSummary() {
		guard let token = Constants.getKeychainValue(forKey: Constants.KeychainKey.token) else { return }
		
		APIClient.dispatch(APIRouter.SummaryReqDto(headers: APIHeader.Default(token: token), body: APIParameters.SummaryReqDto()))
			.sink(receiveCompletion: { error in
				switch error {
				case .failure(let data):
					switch data {
					default:
						break
					}
				case .finished:
					break
				}
			}, receiveValue: { [weak self] reponse in
				guard let self = self else { return }
				self.summary = (reponse.economicActivityTotalCnt, reponse.economicActivitySumAmt)
//				print(#file, #function, #line, dailyList)
			}).store(in: &cancellable)
	}
	
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

