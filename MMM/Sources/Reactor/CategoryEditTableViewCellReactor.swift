//
//  CategoryEditTableViewCellReactor.swift
//  MMM
//
//  Created by geonhyeong on 10/7/23.
//

import ReactorKit

final class CategoryEditTableViewCellReactor: Reactor {
	// 사용자의 액션
	enum Action {
		case didTapEditButton
	}
	
	// 처리 단위
	enum Mutation {
		case presentEdit
		case setTitle(CategoryHeader)
	}
	
	// 현재 상태를 기록
	struct State {
		var categoryHeader: CategoryHeader
	}
	
	// MARK: Properties
	let initialState: State
	let provider: ServiceProviderProtocol

	// 초기 State 설정
	init(provider: ServiceProviderProtocol, categoryHeader: CategoryHeader) {
		self.initialState = .init(categoryHeader: categoryHeader)
		self.provider = provider
	}
}
//MARK: - Mutate, Reduce
extension CategoryEditTableViewCellReactor {
	/// Action이 들어온 경우, 어떤 처리를 할건지 분기
	func mutate(action: Action) -> Observable<Mutation> {
		switch action {
		case .didTapEditButton:
			return .just(.presentEdit)
//			return provider.categoryProvider.presentTitleEdit(to: currentState.categoryEdit).map {
//				_ in .presentEdit
//			}
		}
	}
//	
//	/// 각각의 stream을 변형
//	func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
//		let event = provider.categoryProvider.event.flatMap { event -> Observable<Mutation> in
//			switch event {
//			case .presentTitleEdit:
//				return .empty()
//			case let .updateTitleEdit(categoryEdit):
//				return .just(.setTitle(categoryEdit))
//			case .deleteTitleEdit:
//				return .empty()
//			case .addCategory:
//				return .empty()
//			}
//		}
//		
//		return Observable.merge(mutation, event)
//	}
//	
	/// 이전 상태와 처리 단위(Mutation)를 받아서 다음 상태(State)를 반환하는 함수
	func reduce(state: State, mutation: Mutation) -> State {
		var newState = state
		
		switch mutation {
		case let .setTitle(categoryHeader):
			guard newState.categoryHeader.id == categoryHeader.id else {
				break
			}
			newState.categoryHeader = categoryHeader
		case .presentEdit:
			break
		}
		
		return newState
	}
}
