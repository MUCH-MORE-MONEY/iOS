//
//  HomeViewModel.swift
//  MMM
//
//  Created by geonhyeong on 2023/04/12.
//

import Foundation
import Combine
import UIKit

final class HomeViewModel {
	// MARK: - Property Warraper
	@Published var passwordInput: String = ""
	@Published var passwordConfirmInput: String = ""
	@Published var dailyList: [EconomicActivity] = []
	@Published var monthlyList: [Monthly] = []

	// MARK: - Private properties
	private var cancellable: Set<AnyCancellable> = .init()
	
	// MARK: - Public properties
	// 들어온 퍼블리셔들의 값 일치 여부를 반환하는 퍼블리셔
	lazy var isMatchPasswordInput: AnyPublisher<Bool, Never> = Publishers
		.CombineLatest($passwordInput, $passwordConfirmInput)
		.map( { (password: String, passwordConfirm: String) in
			if password == "" || passwordConfirm == "" {
				return false
			}
			if password == passwordConfirm {
				return true
			} else {
				return false
			}
		})
		.eraseToAnyPublisher()
	
	init() {
		self.getDailyList(Date().getFormattedYMD())
		self.getMonthlyList(Date().getFormattedYM())
	}
}

//MARK: Action
extension HomeViewModel {
	func getDailyList(_ dateYMD: String) {
		guard let date = Int(dateYMD), let token = Constants.getKeychainValue(forKey: Constants.KeychainKey.token) else { return }
		
		APIClient.dispatch(APIRouter.SelectListDailyReqDto(headers: APIHeader.Default(token: TempToken.token), body: APIParameters.SelectListDailyReqDto(dateYMD: date)))
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
				guard let self = self, let dailyList = reponse.selectListDailyOutputDto else { return }
//				print(#file, #function, #line, dailyList)
				self.dailyList = dailyList
			})
			.store(in: &cancellable)
	}
	
	func getMonthlyList(_ dateYM: String) {
		guard let date = Int(dateYM), let token = Constants.getKeychainValue(forKey: Constants.KeychainKey.token) else { return }
		
		APIClient.dispatch(APIRouter.SelectListMonthlyReqDto(headers: APIHeader.Default(token: TempToken.token), body: APIParameters.SelectListMonthlyReqDto(dateYM: date)))
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
				guard let self = self, let monthlyList = reponse.selectListMonthlyOutputDto else { return }
//				print(#file, #function, #line, monthlyList)
				self.monthlyList = monthlyList
			})
			.store(in: &cancellable)
	}
}

//MARK: State
extension HomeViewModel {
	
}
