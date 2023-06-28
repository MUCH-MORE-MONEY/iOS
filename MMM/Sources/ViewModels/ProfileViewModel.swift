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
	@Published var file: (fileName: String, data: Data)?

	private var cancellable: Set<AnyCancellable> = .init()
}
extension ProfileViewModel {
	/// 경제활동 요약
	func getSummary() {
		guard let token = Constants.getKeychainValue(forKey: Constants.KeychainKey.token) else { return }
		
		isLoading = true // 로딩 시작
		APIClient.dispatch(APIRouter.SummaryReqDto(headers: APIHeader.Default(token: token), body: APIParameters.SummaryReqDto()))
			.sink(receiveCompletion: { [weak self] error in
				guard let self = self else { return }
				
				switch error {
				case .failure(let data):
					switch data {
					default:
						break
					}
				case .finished:
					break
				}
				isLoading = false // 로딩 종료
			}, receiveValue: { [weak self] response in
				guard let self = self else { return }
				self.summary = (response.economicActivityTotalCnt, response.economicActivitySumAmt)
//				print(#file, #function, #line, dailyList)
			}).store(in: &cancellable)
	}
	
	/// 데이터 내보내기
	func exportToExcel() {
		guard let token = Constants.getKeychainValue(forKey: Constants.KeychainKey.token) else { return }
		
		isLoading = true // 로딩 시작
		APIClient.dispatch(APIRouter.ExportReqDto(headers: APIHeader.Default(token: token), body: APIParameters.ExportReqDto()))
			.sink(receiveCompletion: { [weak self] error in
				guard let self = self else { return }
				
				switch error {
				case .failure(let data):
					switch data {
					default:
						DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
							self.isLoading = false // 에러일 경우 로딩 끝
						}
					}
				case .finished:
					break
				}
			}, receiveValue: { [weak self] response in
				guard let self = self, let data = Data(base64Encoded: response.binaryData) else { return }
				file = (response.fileNm, data)
//				print(#file, #function, #line, response)
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
			.sink(receiveCompletion: {[weak self] error in
				guard let self = self else { return }
				
				switch error {
				case .failure(let data):
					switch data {
					default:
						break
					}
				case .finished:
					break
				}
				isWithdraw = false // 로딩 종료
			}, receiveValue: { [weak self] response in
				guard let self = self else { return }
				
				// 사용자 모든 정보 제거
				Constants.removeAllKeychain()
				
				isWithdraw = false // 로딩 종료
			}).store(in: &cancellable)
	}
}
