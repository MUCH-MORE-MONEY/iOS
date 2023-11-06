//
//  ChallengeReactor.swift
//  MMM
//
//  Created by geonhyeong on 11/6/23.
//

import ReactorKit

final class ChallengeReactor: Reactor {
	// 사용자의 액션
	enum Action {
		case didTapSuggestion
	}
	
	// 처리 단위
	enum Mutation {
		case connectLink(Bool) // 제안하기
	}
	
	// 현재 상태를 기록
	struct State {
		var isConnect: Bool = false
	}
	
	// MARK: Properties
	let initialState: State
	
	// 초기 State 설정
	init() {
		initialState = .init()
	}
}
//MARK: - Mutate, Reduce
extension ChallengeReactor {
	/// Action이 들어온 경우, 어떤 처리를 할건지 분기
	func mutate(action: Action) -> Observable<Mutation> {
		switch action {
		case .didTapSuggestion: 
			return .concat([
				.just(.connectLink(true)),
				.just(.connectLink(false))
			])
		}
	}
	
	/// 이전 상태와 처리 단위(Mutation)를 받아서 다음 상태(State)를 반환하는 함수
	func reduce(state: State, mutation: Mutation) -> State {
		var newState = state
		
		switch mutation {
		case let .connectLink(isConnect):
			newState.isConnect = isConnect
		}
		
		return newState
	}
}
