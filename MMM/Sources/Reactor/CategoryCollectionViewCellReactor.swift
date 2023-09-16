//
//  CategoryCollectionViewCellReactor.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/16.
//

import ReactorKit

final class CategoryCollectionViewCellReactor: Reactor {
	// 사용자의 액션
	enum Action {
	}
	
	// 처리 단위
	enum Mutation {
	}
	
	// 현재 상태를 기록
	struct State {
		let category: Category
	}
	
	// MARK: Properties
	let initialState: State
	
	// 초기 State 설정
	init(category: Category) {
		initialState = .init(category: category)
	}
}
//MARK: - Mutate, Reduce 함수
extension CategoryCollectionViewCellReactor {
	/// Action이 들어온 경우, 어떤 처리를 할건지 분기
	func mutate(action: Action) -> Observable<Mutation> {
	}
	
	/// 이전 상태와 처리 단위(Mutation)를 받아서 다음 상태(State)를 반환하는 함수
	func reduce(state: State, mutation: Mutation) -> State {
		var newState = state
		
		switch mutation {
		}
		
		return newState
	}
}
