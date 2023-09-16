//
//  CategoryReactor.swift
//  MMM
//
//  Created by geonhyeong on 2023/08/23.
//

import ReactorKit

final class CategoryReactor: Reactor {
	// 사용자의 액션
	enum Action {
		case loadData
		case fetch
		case selectCell(IndexPath, CategoryItem)
	}
	
	// 처리 단위
	enum Mutation {
		case setSections([CategorySectionModel])
	}
	
	// 현재 상태를 기록
	struct State {
		var sections: [CategorySectionModel] = []
		var error = false
	}
	
	// MARK: Properties
	let initialState: State
	
	init() {
		initialState = State()
		
		// 뷰가 최초 로드 될 경우
		action.onNext(.loadData)
	}
}
//MARK: - Mutate, Reduce 함수
extension CategoryReactor {
	/// Action이 들어온 경우, 어떤 처리를 할건지 분기
	func mutate(action: Action) -> Observable<Mutation> {
		switch action {
		case .loadData:
			return .concat([
				.just(.setSections(makeSections()))
			])
		case .fetch, .selectCell:
			return .empty()
		}
	}
	
	/// 이전 상태와 처리 단위(Mutation)를 받아서 다음 상태(State)를 반환하는 함수
	func reduce(state: State, mutation: Mutation) -> State {
		var newState = state
		
		switch mutation {
		case .setSections(let sections):
			newState.sections = sections
		}
		
		return newState
	}
}
//MARK: - Actions
extension CategoryReactor {
	// Section에 따른 Data 주입
	private func makeSections() -> [CategorySectionModel] {
		var categoryitems: [CategoryItem] = []
		
		let firstSectionModel: CategorySectionModel = .init(model: .base(categoryitems), items: categoryitems)
		let secondSectionModel: CategorySectionModel = .init(model: .base(categoryitems), items: categoryitems)

		return [firstSectionModel, secondSectionModel]
	}
}
