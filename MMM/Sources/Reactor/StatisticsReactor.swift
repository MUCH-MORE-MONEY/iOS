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
		case pagination(contentHeight: CGFloat, contentOffsetY: CGFloat, scrollViewHeight: CGFloat) // pagination
		case didTapMoreButton // 카테고리 더보기
		case didTapSatisfactionButton // 만족도 선택
		case selectCell(IndexPath, EconomicActivity)
	}
	
	// 처리 단위
	enum Mutation {
		case fetchList([EconomicActivity], String, Bool) // list, type("01" or "03"), rank reset 여부
		case pagenation([EconomicActivity], Int)
		case fetchCategoryBar([CategoryBar], String)
		case setDate(Date)
		case setSatisfaction(Satisfaction)
		case setAverage(Double)
		case presentSatisfaction(Bool)
		case pushMoreCategory(Bool)
		case pushDetail(IndexPath, EconomicActivity, Bool)
		case setLoading(Bool)
		case setError
	}
	
	// 현재 상태를 기록
	struct State {
		var date = Date() // 월
		var average: Double = 0.0 // 평균값
		var satisfaction: Satisfaction = .low // 만족도
		var activityList: [EconomicActivity] = []
		var payBarList: [CategoryBar] = []		// 지출 카테고리
		var earnBarList: [CategoryBar] = []	// 수입 카테고리
		var activitySatisfactionList: [EconomicActivity] = []
		var activityDisappointingList: [EconomicActivity] = []
		var isLoading = false // 로딩
		var isPushMoreCategory = false
		var isPresentSatisfaction = false
		var isPushDetail = false
		var detailData: (IndexPath: IndexPath, info: EconomicActivity)?
		var curSatisfaction: Satisfaction = .low
	}
	
	// MARK: Properties
	let initialState: State
	let provider: ServiceProviderProtocol
	var currentPage: Int = 0
	
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
			return .concat([
				.just(.setLoading(true)),
				self.getStatisticsAverage(currentState.date), // 평균값
				self.getCategory(currentState.date, "01"),	// 지출 카테고리
				self.getCategory(currentState.date, "02"),	// 수입 카테고리
				self.getStatisticsList(currentState.date, "01", true), // 아쉬운 List
				self.getStatisticsList(currentState.date, "03", true), // 만족스러운 List
				self.getStatisticsList(currentState.date, self.currentState.satisfaction.id, true), // viewWillAppear일때, 현재 만족도를 불러와야한다.
				.just(.setLoading(false))
			])
		case let .pagination(contentHeight, contentOffsetY, scrollViewHeight):
			  let paddingSpace = contentHeight - contentOffsetY
			  if paddingSpace < scrollViewHeight {
				return getMoreStatisticsList()
			  } else {
				return .empty()
			  }
		case .didTapMoreButton:
			return .concat([
				.just(.pushMoreCategory(true)),
				.just(.pushMoreCategory(false))
			])
		case .didTapSatisfactionButton:
			return .concat([
				.just(.presentSatisfaction(true)),
				.just(.presentSatisfaction(false))
			])
		case .selectCell(let indexPath, let data):
			return .concat([
				.just(.pushDetail(indexPath, data, true)),
				.just(.pushDetail(indexPath, data, false))
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
					self.getCategory(date, "02"),
					self.getCategory(date, "01"),
					self.getStatisticsList(date, "01", true),
					self.getStatisticsList(date, "03", true),
					self.getStatisticsList(date, self.currentState.satisfaction.id, true), // viewWillAppear일때, 현재 만족도를 불러와야한다.
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
		case .fetchList(let list, let type, let reset):
			let data = list.prefix(3)
			newState.activityList = list
			currentPage = 0
			
			// 월 변경인지 판별
			if reset {
				switch type {
				case "01": // 아쉬운 활동
					newState.activityDisappointingList = list.suffix(1) + data
				case "03": // 만족스러운 활동
					newState.activitySatisfactionList = [] + data + list.prefix(1)
				default:
					break
				}
			}
		case .pagenation(let list, let nextIndex):
			if nextIndex == -1 { break }
			newState.activityList += list
		case .fetchCategoryBar(let list, let type):
			switch type {
			case "01": newState.payBarList = list
			case "02": newState.earnBarList = list
			default: break
			}
		case .setDate(let date):
			newState.date = date
		case .setAverage(let average):
			newState.average = average
		case .setSatisfaction(let satisfaction):
			newState.satisfaction = satisfaction
		case .setLoading(let isLoading):
			newState.isLoading = isLoading
		case .presentSatisfaction(let isPresent):
			newState.isPresentSatisfaction = isPresent
		case .pushMoreCategory(let isPush):
			newState.isPushMoreCategory = isPush
		case .pushDetail(let indexPath, let data, let isPush):
			newState.isPushDetail = isPush
			newState.detailData = (indexPath, data)
		case .setError:
			newState.isLoading = false
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
			.catchAndReturn(.setError)
	}
	
	// 경제활동 만족도에 따른 List 불러오기
	func getStatisticsList(_ date: Date, _ type: String, _ reset: Bool = false) -> Observable<Mutation> {
		return MMMAPIService().getStatisticsList(dateYM: date.getFormattedYM(), valueScoreDvcd: type, limit: 15, offset: 0)
			.map { (response, error) -> Mutation in
				return .fetchList(response.selectListMonthlyByValueScoreOutputDto, type, reset)
			}
			.catchAndReturn(.setError)
	}
	
	// Pagenation
	func getMoreStatisticsList() -> Observable<Mutation> {
		let date = currentState.date.getFormattedYM()
		let type = currentState.satisfaction.id
		currentPage += 1
		
		return MMMAPIService().getStatisticsList(dateYM: date, valueScoreDvcd: type, limit: 15, offset: currentPage)
			.map { (response, error) -> Mutation in
				return .pagenation(response.selectListMonthlyByValueScoreOutputDto, response.nextOffset)
			}
			.catchAndReturn(.setError)
	}
	
	// 카테고리 Bar 가져오기
	private func getCategory(_ date: Date, _ type: String) -> Observable<Mutation> {
		return MMMAPIService().getStatisticsCategory(dateYM: date.getFormattedYM(), economicActivityDvcd: type)
			.map { (response, error) -> Mutation in
				return .fetchCategoryBar(response.data.setSelectListMonthlyByUpperCategoryOutputDto, type)
			}
			.catchAndReturn(.setError)
	}
}
