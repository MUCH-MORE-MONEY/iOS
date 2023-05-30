//
//  HomeViewModel.swift
//  MMM
//
//  Created by geonhyeong on 2023/04/12.
//

import UIKit
import Combine
import SwiftKeychainWrapper

final class HomeViewModel {
	// MARK: - Property Warraper
	@Published var dailyList: [EconomicActivity] = []
	@Published var monthlyList: [Monthly] = []
	@Published var didTapHighlightButton: Bool?	// bottom sheet
	@Published var didTapColorButton: Bool?		// bottom sheet
	@Published var date: Date = Date()
	@Published var isHighlight: Bool = Constants.getKeychainValueByBool(forKey: Constants.KeychainKey.isHighlight) ?? true {
		// 금액 하이라이트 설정
		didSet {
			Constants.setKeychain(isHighlight, forKey: Constants.KeychainKey.isHighlight)
		}
	}
	@Published var isDailySetting: Bool = Constants.getKeychainValueByBool(forKey: Constants.KeychainKey.isDailySetting) ?? true {
		// 일별 금액 합계 설정
		didSet {
			Constants.setKeychain(isDailySetting, forKey: Constants.KeychainKey.isDailySetting)
		}
	}
	@Published var earnStandard: Int = Constants.getKeychainValueByInt(forKey: Constants.KeychainKey.earnStandard) ?? 10_000 {
		// 금액 하이라이트 설정 - 수입
		didSet {
			Constants.setKeychain(earnStandard, forKey: Constants.KeychainKey.earnStandard)
		}
	}
	@Published var payStandard: Int = Constants.getKeychainValueByInt(forKey: Constants.KeychainKey.payStandard) ?? 10_000 {
		// 금액 하이라이트 설정 - 지출
		didSet {
			Constants.setKeychain(payStandard, forKey: Constants.KeychainKey.payStandard)
		}
	}

	// MARK: - Private properties
	private var cancellable: Set<AnyCancellable> = .init()
		
	init() {
		self.getDailyList(Date().getFormattedYMD())
		self.getMonthlyList(Date().getFormattedYM())
	}
}
//MARK: Action
extension HomeViewModel {
	func getDailyList(_ dateYMD: String) {
		guard let date = Int(dateYMD), let _ = Constants.getKeychainValue(forKey: Constants.KeychainKey.token) else { return }
		
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
			}).store(in: &cancellable)
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
				guard let self = self, let monthlyList = reponse.monthly else { return }
//				print(#file, #function, #line, monthlyList)
				self.monthlyList = monthlyList
			}).store(in: &cancellable)
	}
	
	func getWeeklyList(_ date1YM: String, _ date2YM: String) {
		guard let date1 = Int(date1YM), let date2 = Int(date2YM), let token = Constants.getKeychainValue(forKey: Constants.KeychainKey.token) else { return }
		
		APIClient.dispatch(APIRouter.SelectListMonthlyReqDto(headers: APIHeader.Default(token: TempToken.token), body: APIParameters.SelectListMonthlyReqDto(dateYM: date1)))
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
			}, receiveValue: { [weak self] reponse1 in
				guard let self = self, let monthlyList1 = reponse1.monthly else { return }
//				print(#file, #function, #line, monthlyList)
				
				APIClient.dispatch(APIRouter.SelectListMonthlyReqDto(headers: APIHeader.Default(token: TempToken.token), body: APIParameters.SelectListMonthlyReqDto(dateYM: date2)))
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
					}, receiveValue: { [weak self] reponse2 in
						guard let self = self, let monthlyList2 = reponse2.monthly else { return }
		//				print(#file, #function, #line, monthlyList)
						self.monthlyList = monthlyList1 + monthlyList2
					}).store(in: &self.cancellable)
			}).store(in: &cancellable)
	}
}
