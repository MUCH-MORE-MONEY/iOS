//
//  HomeViewModel.swift
//  MMM
//
//  Created by geonhyeong on 2023/04/12.
//

import UIKit
import Combine
import WidgetKit

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
	@Published var isDailyLoading = false
	@Published var isMonthlyLoading = false
	@Published var errorDaily: Bool?	// 에러 이미지 노출 여부
	@Published var errorMonthly: Bool?	// 에러 이미지 노출 여부

	// MARK: - Private properties
	private var cancellable: Set<AnyCancellable> = .init()
		
	init() {
		self.getDailyList(Date().getFormattedYMD())
		self.getMonthlyList(Date().getFormattedYM())
	}
	
	// 월별, 일별 데이터 가져오기
	lazy var isLoading: AnyPublisher<Bool, Never> = Publishers.CombineLatest($isDailyLoading, $isMonthlyLoading)
		.map { $0 || $1 } // 둘중 하나라도 Loading 중이면
		.eraseToAnyPublisher()
}
//MARK: Action
extension HomeViewModel {
	func getDailyList(_ dateYMD: String) {
		guard let date = Int(dateYMD), let token = Constants.getKeychainValue(forKey: Constants.KeychainKey.token) else { return }
		
		isDailyLoading = true // 로딩 시작

		APIClient.dispatch(APIRouter.SelectListDailyReqDto(headers: APIHeader.Default(token: token), body: APIParameters.SelectListDailyReqDto(dateYMD: date)))
			.sink(receiveCompletion: { [weak self] error in
				guard let self = self else { return }

				switch error {
				case .failure(let data):
					switch data {
					default:
						errorDaily = true // 에러 표시
					}
				case .finished:
					break
				}
				isDailyLoading = false // 로딩 종료
			}, receiveValue: { [weak self] response in
				guard let self = self, let dailyList = response.selectListDailyOutputDto else { return }
//				print(#file, #function, #line, dailyList)
				self.dailyList = dailyList
				isDailyLoading = false // 로딩 종료
				errorDaily = false // 에러 이미지 제거
			}).store(in: &cancellable)
	}
	
	func getMonthlyList(_ dateYM: String) {
		guard let date = Int(dateYM), let token = Constants.getKeychainValue(forKey: Constants.KeychainKey.token) else { return }
		
		isMonthlyLoading = true // 로딩 시작

		APIClient.dispatch(APIRouter.SelectListMonthlyReqDto(headers: APIHeader.Default(token: token), body: APIParameters.SelectListMonthlyReqDto(dateYM: date)))
			.sink(receiveCompletion: { [weak self] error in
				guard let self = self else { return }
				
				switch error {
				case .failure(let data):
					switch data {
					default:
						errorMonthly = true // 에러 표시
					}
				case .finished:
					break
				}
				isMonthlyLoading = false // 로딩 종료
			}, receiveValue: { [weak self] response in
				guard let self = self, let monthlyList = response.monthly else { return }
//				print(#file, #function, #line, monthlyList)
				self.monthlyList = monthlyList
				
				// 이번 달만 위젯에 보여줌
				if dateYM == Date().getFormattedYM() {
					UserDefaults.shared.set(response.earn, forKey: "earn")
					UserDefaults.shared.set(response.pay, forKey: "pay")
					WidgetCenter.shared.reloadAllTimelines()
				}
				isMonthlyLoading = false // 로딩 종료
				errorMonthly = false // 에러 이미지 제거
			}).store(in: &cancellable)
	}
	
	func getWeeklyList(_ date1YM: String, _ date2YM: String) {
		guard let date1 = Int(date1YM), let date2 = Int(date2YM), let token = Constants.getKeychainValue(forKey: Constants.KeychainKey.token) else { return }
		
		isMonthlyLoading = true // 로딩 시작

		APIClient.dispatch(APIRouter.SelectListMonthlyReqDto(headers: APIHeader.Default(token: token), body: APIParameters.SelectListMonthlyReqDto(dateYM: date1)))
			.sink(receiveCompletion: { [weak self] error in
				guard let self = self else { return }
				switch error {
				case .failure(let data):
					switch data {
					default:
						errorMonthly = true // 에러 표시
					}
				case .finished:
					break
				}
				isMonthlyLoading = false // 로딩 종료
			}, receiveValue: { [weak self] response1 in
				guard let self = self, let monthlyList1 = response1.monthly else { return }
//				print(#file, #function, #line, monthlyList)
				
				APIClient.dispatch(APIRouter.SelectListMonthlyReqDto(headers: APIHeader.Default(token: token), body: APIParameters.SelectListMonthlyReqDto(dateYM: date2)))
					.sink(receiveCompletion: { [weak self] error in
						guard let self = self else { return }
						switch error {
						case .failure(let data):
							switch data {
							default:
								errorMonthly = true // 에러 표시
							}
						case .finished:
							break
						}
						isMonthlyLoading = false // 로딩 종료
					}, receiveValue: { [weak self] response2 in
						guard let self = self, let monthlyList2 = response2.monthly else { return }
		//				print(#file, #function, #line, monthlyList)
						self.monthlyList = monthlyList1 + monthlyList2
						
						// 이번 달만 위젯에 보여줌
						if date1YM == Date().getFormattedYM() {
							UserDefaults.shared.set(response1.earn, forKey: "earn")
							UserDefaults.shared.set(response1.pay, forKey: "pay")
							WidgetCenter.shared.reloadAllTimelines()
						} else if date2YM == Date().getFormattedYM() {
							UserDefaults.shared.set(response2.earn, forKey: "earn")
							UserDefaults.shared.set(response2.pay, forKey: "pay")
							WidgetCenter.shared.reloadAllTimelines()
						}
						isMonthlyLoading = false // 로딩 종료
						errorMonthly = false // 에러 이미지 제거
					}).store(in: &self.cancellable)
			}).store(in: &cancellable)
	}
}
