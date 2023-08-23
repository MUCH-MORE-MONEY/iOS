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
		case didTapCheckButton(date: Date)
	}
	
	// 처리 단위
	enum Mutation {
		case updateData(Date)
	}
	
	// 현재 상태를 기록
	struct State {
		var success: Date = Date()
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
		case .didTapCheckButton(let date):
			return .just(.updateData(date))
		}
	}
	
	/// 이전 상태와 처리 단위(Mutation)를 받아서 다음 상태(State)를 반환하는 함수
	func reduce(state: State, mutation: Mutation) -> State {
		var newState = state
		
		switch mutation {
		case .updateData(let date):
			newState.success = date
		}
		
		return newState
	}
}
