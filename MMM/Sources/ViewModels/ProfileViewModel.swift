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
	@Published var summary: (recordCnt: Int?, recordSumAmount: Int?)?
	@Published var isLoading = false
	@Published var isWithdraw: Bool?

	private var cancellable: Set<AnyCancellable> = .init()
}
extension ProfileViewModel {
	/// 경제활동 요약
	func getSummary() {
		guard let token = Constants.getKeychainValue(forKey: Constants.KeychainKey.token) else { return }
		
		isLoading = true // 로딩 시작
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
			}, receiveValue: { [weak self] response in
				guard let self = self else { return }
				self.summary = (response.economicActivityTotalCnt, response.economicActivitySumAmt)
				isLoading = false // 로딩 종료
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
		guard let token = Constants.getKeychainValue(forKey: Constants.KeychainKey.token) else { return }
		
		isWithdraw = true // 로딩 시작
		APIClient.dispatch(APIRouter.WithdrawReqDto(headers: APIHeader.Default(token: token), body: APIParameters.WithdrawReqDto()))
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
			}, receiveValue: { [weak self] response in
				guard let self = self else { return }
				
				// 사용자 모든 정보 제거
				Constants.removeAllKeychain()
				
				isWithdraw = false // 로딩 종료
			}).store(in: &cancellable)
	}
}

