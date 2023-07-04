//
//  HomeDetailViewModel.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/05/11.
//

import UIKit
import Combine
import WidgetKit

final class HomeDetailViewModel {
	// MARK: - Property Wrapper
	@Published var detailActivity: SelectDetailResDto?
	@Published var hasImage = false
	@Published var mainImage: UIImage?
//	@Published var isShowToastMessage = false
	@Published var isLoading = true
    @Published var isError = false
    @Published var dailyEconomicActivityId: [String] = []
	// MARK: - Porperties
	private var cancellable: Set<AnyCancellable> = []
    // 날짜가 바뀌었을 경우를 판단하는 변수
    var isDateChanged = false
	var changedDate = Date()
    var changedId = ""
    // pageControl의 index
    @Published var pageIndex: Int = 0
    
    func fetchDailyList(_ dateYMD: String, completion: @escaping () -> Void) {
        guard let date = Int(dateYMD), let token = Constants.getKeychainValue(forKey: Constants.KeychainKey.token) else { return }
        self.isLoading = true
        APIClient.dispatch(APIRouter.SelectListDailyReqDto(headers: APIHeader.Default(token: token), body: APIParameters.SelectListDailyReqDto(dateYMD: date)))
            .sink(receiveCompletion: { [weak self] error in
                guard let self = self else { return }

                switch error {
                case .failure(let data):
                    switch data {
                    default:

                        break
//                        errorDaily = true // 에러 표시
                    }
                case .finished:
                    break
                }
//                isDailyLoading = false // 로딩 종료
            }, receiveValue: { [weak self] response in
                guard let self = self, let dailyList = response.selectListDailyOutputDto else { return }
                isError = false
                self.dailyEconomicActivityId = dailyList.map{ $0.id }
//                isDailyLoading = false // 로딩 종료
//                errorDaily = false // 에러 이미지 제거
                self.isLoading = true
                completion()
            }).store(in: &cancellable)
    }
    
	func fetchDetailActivity(id: String) {
		guard let token = Constants.getKeychainValue(forKey: Constants.KeychainKey.token) else { return }
		self.isLoading = true
		APIClient.dispatch(
			APIRouter.SelectDetailReqDto(
				headers: APIHeader.Default(token: token),
				body: APIParameters.SelectDetailReqDto(economicActivityNo: id)))
		.sink { error in
			switch error {
			case .failure:
                self.isError = true
			case .finished:
				break
			}
            self.isLoading = false
		} receiveValue: { [weak self] response in
			guard let self = self else { return }
            isError = false
			self.detailActivity = response
		}.store(in: &cancellable)
	}
	
    func fetchDetailActivity(id: String, completion: @escaping () -> Void) {
        guard let token = Constants.getKeychainValue(forKey: Constants.KeychainKey.token) else { return }
        self.isLoading = true
        APIClient.dispatch(
            APIRouter.SelectDetailReqDto(
                headers: APIHeader.Default(token: token),
                body: APIParameters.SelectDetailReqDto(economicActivityNo: id)))
        .sink { error in
            switch error {
            case .failure(let data):
                switch data {
                case .error4xx(_):
                    print("400")
                    break
                case .error5xx(_):
                    print("500")
                    break
                case .decodingError(_):
                    print("디코딩에러")
                    break
                case .urlSessionFailed(_):
                    print("url 세션 에러")
                    break
                case .timeOut:
                    print("시간 초과")
                    break
                case .unknownError:
                    print("unknownError")
                    break
                default:
                    break
                }
            case .finished:
                break
            }
        } receiveValue: { [weak self] response in
            guard let self = self else { return }
            self.detailActivity = response
            self.isLoading = false
            completion()
        }.store(in: &cancellable)
    }
    
	func getMonthlyList(_ dateYM: String) {
		guard let date = Int(dateYM), let token = Constants.getKeychainValue(forKey: Constants.KeychainKey.token) else { return }
		
		APIClient.dispatch(APIRouter.SelectListMonthlyReqDto(headers: APIHeader.Default(token: token), body: APIParameters.SelectListMonthlyReqDto(dateYM: date)))
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
				// 이번 달만 위젯에 보여줌
				if dateYM == Date().getFormattedYM() {
					UserDefaults.shared.set(response.earn, forKey: "earn")
					UserDefaults.shared.set(response.pay, forKey: "pay")
					WidgetCenter.shared.reloadAllTimelines()
				}
			}).store(in: &cancellable)
	}

}
