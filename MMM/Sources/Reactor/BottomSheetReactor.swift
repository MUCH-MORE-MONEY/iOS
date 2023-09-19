//
//  BottomSheetReactor.swift
//  MMM
//
//  Created by geonhyeong on 2023/08/22.
//

import Foundation
import ReactorKit

final class BottomSheetReactor: Reactor {
	// 사용자의 액션
	enum Action {
		case didTapDateCheckButton(date: Date) // 월
		case didTapSatisfactionCheckButton(type: Satisfaction) // 만족도
	}
	
	// 처리 단위
	enum Mutation {
		case updateDataByMonthly(Date)
		case updateDataBySatisfaction(Satisfaction)
	}
	
	// 현재 상태를 기록
	struct State {
		var successByMonthly: Date = Date()
		var successBySatisfaction: Satisfaction = .low
		var error = false
	}
	
	// MARK: Properties
	let initialState: State
	
	init() { initialState = State() }
}
//MARK: - Mutate, Reduce
extension BottomSheetReactor {
	/// Action이 들어온 경우, 어떤 처리를 할건지 분기
	func mutate(action: Action) -> Observable<Mutation> {
		switch action {
		case .didTapDateCheckButton(let date):
			return .just(.updateDataByMonthly(date))
		case .didTapSatisfactionCheckButton(let satisfaction):
			return .just(.updateDataBySatisfaction(satisfaction))
		}
	}
	
	/// 이전 상태와 처리 단위(Mutation)를 받아서 다음 상태(State)를 반환하는 함수
	func reduce(state: State, mutation: Mutation) -> State {
		var newState = state
		
		switch mutation {
		case .updateDataByMonthly(let date):
			newState.successByMonthly = date
		case .updateDataBySatisfaction(let satisfaction):
			newState.successBySatisfaction = satisfaction
		}
		
		return newState
	}
}
//MARK: - Actions
extension BottomSheetReactor {
	// 경제활동 만족도 평균값 불러오기
	func getStatisticsAverage(_ date: Date) -> Observable<Mutation> {
		return MMMAPIService().getStatisticsAverage(date.getFormattedYM())
			.map { (response, error) -> Mutation in
				return .updateDataByMonthly(date, response, error)
			}
	}
}
