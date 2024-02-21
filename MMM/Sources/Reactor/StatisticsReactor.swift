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
		case selectCell(IndexPath, StatisticsItem)
        case didTapNewTitleView      // 예산 설정하기 탭(임시로 averageView에 넣음)
	}
	
	// 처리 단위
	enum Mutation {
		case setList([EconomicActivity], String, Bool) // list, type("01" or "03"), rank reset 여부
		case pagenation([EconomicActivity], Int)
		case fetchCategoryBar([CategoryBar], String)
		case setDate(Date)
		case setSatisfaction(Satisfaction)
		case setAverage(Double)
		case presentSatisfaction(Bool)
		case pushMoreCategory(Bool)
		case pushDetail(IndexPath, EconomicActivity, Bool)
        case pushBudgetSetting(Bool)
		case setLoading(Bool)
		case setError
	}
	
	// 현재 상태를 기록
	struct State {
		var date = Date() // 월
		var average: Double = 0.0 // 평균값
		var satisfaction: Satisfaction = .low // 만족도
		var activityList: [StatisticsSectionModel] = []
		var payBarList: [CategoryBar] = []		// 지출 카테고리
		var earnBarList: [CategoryBar] = []		// 수입 카테고리
		var activitySatisfactionList: [EconomicActivity] = []
		var activityDisappointingList: [EconomicActivity] = []
		var isLoading = true // 로딩
		var isPushMoreCategory = false
		var isPresentSatisfaction = false
		var isPushDetail = false
		var detailData: (IndexPath: IndexPath, info: EconomicActivity)?
		var curSatisfaction: Satisfaction = .low
		var totalItem: Int = 0  // item의 총 갯수
		var isInit = true // 최초진입
        @Pulse var isPushBudgetSetting = false
	}
	
	// MARK: Properties
	let initialState: State
	let provider: ServiceProviderProtocol
	var currentPage: Int = 0
	var totalPage: Int = 0
    var totalItem: Int = 0
    
	init(provider: ServiceProviderProtocol) {
		self.initialState = State()
		self.provider = provider
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
		case let .selectCell(indexPath, data):
			guard let item = data.item else { return .empty() }
			
			return .concat([
				.just(.pushDetail(indexPath, item, true)),
				.just(.pushDetail(indexPath, item, false))
			])
        case .didTapNewTitleView:
            return .concat([
                .just(.pushBudgetSetting(true)),
                .just(.pushBudgetSetting(false))
            ])
		}
	}
	
	/// 각각의 stream을 변형
	func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
		let event = provider.statisticsProvider.event.flatMap { event -> Observable<Mutation> in
			switch event {
			case let .updateDate(date):
				return .concat([
					.just(.setDate(date)),
					self.getStatisticsAverage(date),
					self.getCategory(date, "02"),
					self.getCategory(date, "01"),
					self.getStatisticsList(date, "01", true),
					self.getStatisticsList(date, "03", true),
					self.getStatisticsList(date, self.currentState.satisfaction.id) // viewWillAppear일때, 현재 만족도를 불러와야한다.
				])
			case let .updateSatisfaction(satisfaction):
				return .concat([
					.just(.setSatisfaction(satisfaction)),
					self.getStatisticsList(self.currentState.date, satisfaction.id),
				])
			}
		}
		
		return Observable.merge(mutation, event)
	}
	
	/// 이전 상태와 처리 단위(Mutation)를 받아서 다음 상태(State)를 반환하는 함수
	func reduce(state: State, mutation: Mutation) -> State {
		var newState = state
		
		switch mutation {
		case let .setList(list, type, reset):
			newState.isInit = false
			
			// 현재의 만족도에 대한 데이터를 호출 할때만 Update
			if type == currentState.satisfaction.id {
				newState.activityList = convertSectionModel(list)
			}

			let data = list.prefix(3)
			currentPage = 0
			// 월 변경인지 판별
			if reset {
				switch type {
				case "01": // 아쉬운 활동
					newState.activityDisappointingList = [] + data + list.prefix(1)
				case "03": // 만족스러운 활동
					newState.activitySatisfactionList = [] + data + list.prefix(1)
				default:
					break
				}
			}
		case let .pagenation(list, totalPage):
			self.totalPage = totalPage
			newState.activityList += convertSectionModel(list)
		case let .fetchCategoryBar(list, type):
			switch type {
			case "01": newState.payBarList = list
			case "02": newState.earnBarList = list
			default: break
			}
		case let .setDate(date):
			newState.date = date

			// 카테고리 추가할때 사용하기 위해 저장
			Constants.setKeychain(date.getFormattedYMD(), forKey: Constants.KeychainKey.statisticsDate)
		case let .setAverage(average):
			newState.average = average
		case let .setSatisfaction(satisfaction):
            switch satisfaction {
            case .hight:
                Tracking.StatiBudget.rating45LogEvent()
            case .middle:
                Tracking.StatiBudget.rating3LogEvent()
            case .low:
                Tracking.StatiBudget.rating12LogEvent()
            }
			newState.satisfaction = satisfaction
		case let .setLoading(isLoading):
			newState.isLoading = isLoading
		case let .presentSatisfaction(isPresent):
			newState.isPresentSatisfaction = isPresent
		case let .pushMoreCategory(isPush):
			newState.isPushMoreCategory = isPush
		case let .pushDetail(indexPath, data, isPush):
			newState.isPushDetail = isPush
			newState.detailData = (indexPath, data)
        case let .pushBudgetSetting(isPush):
            newState.isPushBudgetSetting = isPush
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
				self.totalPage = response.totalPageCnt
                self.totalItem = response.totalItemCnt
				return .setList(response.selectListMonthlyByValueScoreOutputDto, type, reset)
			}
			.catchAndReturn(.setError)
	}
	
	// Pagenation
	func getMoreStatisticsList() -> Observable<Mutation> {
		guard currentPage < totalPage else { return .empty() }
		
		let date = currentState.date.getFormattedYM()
		let type = currentState.satisfaction.id
		currentPage += 1
		
		return MMMAPIService().getStatisticsList(dateYM: date, valueScoreDvcd: type, limit: 15, offset: 15 * currentPage)
			.map { (response, error) -> Mutation in
				return .pagenation(response.selectListMonthlyByValueScoreOutputDto, response.totalPageCnt)
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
	
	private func convertSectionModel(_ list: [EconomicActivity]) -> [StatisticsSectionModel] {
		guard !list.isEmpty else  {
			return []
		}
		
		// Section Model로 변경
		let items = list.map { category -> StatisticsItem in
			return .base(category)
		}
		let model: StatisticsSectionModel = .init(model: "", items: items)
		return [model]
	}
}
