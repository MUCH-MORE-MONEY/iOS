//
//  StatisticsReactor.swift
//  MMM
//
//  Created by geonhyeong on 2023/08/14.
//

import Foundation
import ReactorKit

final class StatisticsReactor: Reactor {
	// 상호작용
	enum Action {
		case increase
		case decrease
	}
	
	// 처리 단위
	enum Mutation {
		case increaseValue
		case decreaseValue
		case setLoading(Bool)
	}
	
	// 현재 상태를 기록
	struct State {
		var value = 0
		var isLoading = false // 로딩
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
		case .increase:
			return Observable.concat([
				Observable.just(.setLoading(true)),
				Observable.just(.increaseValue).delay(.seconds(1), scheduler: MainScheduler.instance),
				Observable.just(.setLoading(false))
			])
		case .decrease:
			return Observable.concat([
				Observable.just(.setLoading(true)),
				Observable.just(.decreaseValue).delay(.seconds(1), scheduler: MainScheduler.instance),
				Observable.just(.setLoading(false))
			])
		}
	}
	
	/// 이전 상태와 처리 단위(Mutation)를 받아서 다음 상태(State)를 반환하는 함수
	func reduce(state: State, mutation: Mutation) -> State {
		var newState = state
		
		switch mutation {
		case .increaseValue:
			newState.value += 1
		case .decreaseValue:
			newState.value -= 1
		case .setLoading(let isLoading):
			newState.isLoading = isLoading
		}
		
		return newState
	}
}
