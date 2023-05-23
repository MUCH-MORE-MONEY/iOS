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
	@Published var isHighlight: Bool = KeychainWrapper.standard.bool(forKey: "isHighlight")! {
		// 금액 하이라이트 설정
		didSet {
			KeychainWrapper.standard.set(isHighlight, forKey: "isHighlight")
		}
	}
	@Published var isDailySetting: Bool = KeychainWrapper.standard.bool(forKey: "isDailySetting")! {
		// 일별 금액 합계 설정
		didSet {
			KeychainWrapper.standard.set(isDailySetting, forKey: "isDailySetting")
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
