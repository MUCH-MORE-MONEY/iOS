//
//  CategoryEditBottomSheetReactor.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/27.
//

import RxSwift
import ReactorKit

final class CategoryEditBottomSheetReactor: Reactor {
	// 사용자의 액션
	enum Action {
		case didTapEdit(CategoryEdit)
		case dismiss
	}
	
	// 처리 단위
	enum Mutation {
		case dismiss
	}
	
	// 현재 상태를 기록
	struct State {
		var dismiss: Bool = false
	}
	
	// MARK: Properties
	let initialState: State
	let provider: ServiceProviderProtocol

	// 초기 State 설정
	init(provider: ServiceProviderProtocol) {
		self.initialState = State()
		self.provider = provider
	}
}
//MARK: - Mutate, Reduce
extension CategoryEditBottomSheetReactor {
	/// Action이 들어온 경우, 어떤 처리를 할건지 분기
	func mutate(action: Action) -> Observable<Mutation> {
		switch action {
		case let .didTapEdit(categoryEdit):
			return provider.categoryProvider.updateTitleEdit(to: categoryEdit).map { _ in .dismiss }
		case .dismiss:
			return .just(.dismiss)
		}
	}
	
	/// 이전 상태와 처리 단위(Mutation)를 받아서 다음 상태(State)를 반환하는 함수
	func reduce(state: State, mutation: Mutation) -> State {
		var newState = state
		
		switch mutation {
		case .dismiss:
			newState.dismiss = true
		}
		
		return newState
	}
}
