//
//  CategoryEditCollectionViewCellReactor.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/24.
//

import ReactorKit

final class CategoryEditCollectionViewCellReactor: Reactor {
	// 사용자의 액션
	enum Action {
		case didTapEditButton
	}
	
	// 처리 단위
	enum Mutation {
		case presentEdit
		case setTitle(String)
	}
	
	// 현재 상태를 기록
	struct State {
		var categoryEdit: CategoryEdit
	}
	
	// MARK: Properties
	let initialState: State
	let provider: ServiceProviderProtocol

	// 초기 State 설정
	init(provider: ServiceProviderProtocol, categoryEdit: CategoryEdit) {
		self.initialState = .init(categoryEdit: categoryEdit)
		self.provider = provider
	}
}
//MARK: - Mutate, Reduce
extension CategoryEditCollectionViewCellReactor {
	/// Action이 들어온 경우, 어떤 처리를 할건지 분기
	func mutate(action: Action) -> Observable<Mutation> {
		switch action {
		case .didTapEditButton:
			return provider.categoryProvider.presentTitleEdit(to: currentState.categoryEdit).map {
				_ in .presentEdit
			}
		}
	}
	
	/// 이전 상태와 처리 단위(Mutation)를 받아서 다음 상태(State)를 반환하는 함수
	func reduce(state: State, mutation: Mutation) -> State {
		var newState = state
		
		switch mutation {
		case let .setTitle(title):
			newState.categoryEdit.title = title
		case .presentEdit:
			break
		}
		
		return newState
	}
}
