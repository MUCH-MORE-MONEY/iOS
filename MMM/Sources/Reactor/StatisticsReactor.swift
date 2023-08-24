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
		case didTapMoreButton // 카테고리 더보기
		case didTapSatisfactionButton // 만족도 선택
	}
	
	// 처리 단위
	enum Mutation {
		case setLoading(Bool)
		case setPushMoreCartegory(Bool)
		case setPresentSatisfaction(Bool)
	}
	
	// 현재 상태를 기록
	struct State {
		var isLoading = false // 로딩
		var isPushMoreCartegory = false
		var isPresentSatisfaction = false
	}
	
	// MARK: Properties
	let initialState: State

	init() { initialState = State() }
}
//MARK: - Mutate, Reduce 함수
extension StatisticsReactor {
	/// Action이 들어온 경우, 어떤 처리를 할건지 분기
	func mutate(action: Action) -> Observable<Mutation> {
		switch action {
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
	
	/// 이전 상태와 처리 단위(Mutation)를 받아서 다음 상태(State)를 반환하는 함수
	func reduce(state: State, mutation: Mutation) -> State {
		var newState = state
		
		switch mutation {
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
