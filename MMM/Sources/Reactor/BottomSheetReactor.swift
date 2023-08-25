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
		case updateData(Date)
		case updateDataBySatisfaction(Satisfaction)
	}
	
	// 현재 상태를 기록
	struct State {
		var success: Date = Date()
		var successBySatisfaction: Satisfaction = .low
		var error = false
	}
	
	// MARK: Properties
	let initialState: State
	
	init() { initialState = State() }
}
//MARK: - Mutate, Reduce 함수
extension BottomSheetReactor {
	/// Action이 들어온 경우, 어떤 처리를 할건지 분기
	func mutate(action: Action) -> Observable<Mutation> {
		switch action {
		case .didTapDateCheckButton(let date):
			return .just(.updateData(date))
		case .didTapSatisfactionCheckButton(let satisfaction):
			return .just(.updateDataBySatisfaction(satisfaction))
		}
	}
	
	/// 이전 상태와 처리 단위(Mutation)를 받아서 다음 상태(State)를 반환하는 함수
	func reduce(state: State, mutation: Mutation) -> State {
		var newState = state
		
		switch mutation {
		case .updateData(let date):
			newState.success = date
		case .updateDataBySatisfaction(let satisfaction):
			newState.successBySatisfaction = satisfaction
		}
		
		return newState
	}
}
