//
//  StatisticsReactor.swift
//  MMM
//
//  Created by geonhyeong on 2023/08/14.
//

import Foundation
import ReactorKit

final class StatisticsReactor: Reactor {
	// 사용자의 액션
	enum Action {
		case loadData
		case didTapMoreButton // 카테고리 더보기
		case didTapSatisfactionButton // 만족도 선택
	}
	
	// 처리 단위
	enum Mutation {
		case fetchList([EconomicActivity])
		case setDate(Date)
		case setSatisfaction(Satisfaction)
		case setAverage(Double)
		case setLoading(Bool)
		case setPushMoreCartegory(Bool)
		case setPresentSatisfaction(Bool)
	}
	
	// 현재 상태를 기록
	struct State {
		var date = Date() // 월
		var average: Double = 0.0 // 평균값
		var satisfaction: Satisfaction = .low // 만족도
		var activityList: [EconomicActivity] = []
		var activitySatisfactionList: [EconomicActivity] = []
		var activityDisappointingList: [EconomicActivity] = []
		var isLoading = false // 로딩
		var isPushMoreCartegory = false
		var isPresentSatisfaction = false
		var curSatisfaction: Satisfaction = .low
	}
	
	// MARK: Properties
	let initialState: State
	let provider: ServiceProviderProtocol

	init(provider: ServiceProviderProtocol) {
		self.initialState = State()
		self.provider = provider

		// 뷰가 최초 로드 될 경우
		action.onNext(.loadData)
	}
}
//MARK: - Mutate, Transform, Reduce
extension StatisticsReactor {
	/// Action이 들어온 경우, 어떤 처리를 할건지 분기
	func mutate(action: Action) -> Observable<Mutation> {
		switch action {
		case .loadData:
			return  Observable.concat([
				.just(.setLoading(true)),
				self.getStatisticsAverage(Date()), // 평균값
				self.getStatisticsList(Date(), self.currentState.satisfaction.id), // 만족도별 List
				.just(.setLoading(false))
			])
		case .didTapMoreButton:
			return  Observable.concat([
				.just(.setPushMoreCartegory(true)),
				.just(.setPushMoreCartegory(false))
			])
		case .didTapSatisfactionButton:
			return  Observable.concat([
				.just(.setPresentSatisfaction(true)),
				.just(.setPresentSatisfaction(false))
			])
		}
	}
	
	/// 각각의 stream을 변형
	func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
		let event = provider.statisticsProvider.event.flatMap { event -> Observable<Mutation> in
			switch event {
			case .updateDate(let date):
				return .concat([
					.just(.setLoading(true)),
					.just(.setDate(date)),
					self.getStatisticsAverage(date),
					self.getStatisticsList(date, "01"),
					.just(.setLoading(false)),
				])
			case .updateSatisfaction(let satisfaction):
				return .concat([
					.just(.setLoading(true)),
					.just(.setSatisfaction(satisfaction)),
					self.getStatisticsList(self.currentState.date, satisfaction.id),
					.just(.setLoading(false))
				])
			}
		}
		
		return Observable.merge(mutation, event)
	}
	
	/// 이전 상태와 처리 단위(Mutation)를 받아서 다음 상태(State)를 반환하는 함수
	func reduce(state: State, mutation: Mutation) -> State {
		var newState = state
		
		switch mutation {
		case .fetchList(let list):
			let data = list.prefix(3)
			newState.activityList = list
			newState.activitySatisfactionList = [] + data + list.prefix(1)
			newState.activityDisappointingList = list.suffix(1) + data
		case .setDate(let date):
			newState.date = date
		case .setAverage(let average):
			newState.average = average
		case .setSatisfaction(let satisfaction):
			newState.satisfaction = satisfaction
		case .setLoading(let isLoading):
			newState.isLoading = isLoading
		case .setPushMoreCartegory(let isPresent):
			newState.isPushMoreCartegory = isPresent
		case .setPresentSatisfaction(let isPresent):
			newState.isPresentSatisfaction = isPresent
		}
		
		return newState
	}
}
//MARK: - Action
extension StatisticsReactor {
	// 경제활동 만족도 평균값 불러오기
	func getStatisticsAverage(_ date: Date) -> Observable<Mutation> {
		return MMMAPIService().getStatisticsAverage(date.getFormattedYM())
			.map { (response, error) -> Mutation in
				return .setAverage(response.economicActivityValueScoreAvg)
			}
	}
	
	// 경제활동 만족도에 따른 List 불러오기
	func getStatisticsList(_ date: Date, _ type: String) -> Observable<Mutation> {
		return MMMAPIService().getStatisticsList(dateYM: date.getFormattedYM(), valueScoreDvcd: type, limit: 25, offset: 0)
			.map { (response, error) -> Mutation in
				return .fetchList(response.selectListMonthlyByValueScoreOutputDto)
			}
	}
}
