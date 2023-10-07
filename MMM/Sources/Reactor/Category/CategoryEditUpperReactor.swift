//
//  CategoryEditUpperReactor.swift
//  MMM
//
//  Created by geonhyeong on 10/7/23.
//

import ReactorKit

final class CategoryEditUpperReactor: Reactor {
	// 사용자의 액션
	enum Action {
		case dragAndDrop(IndexPath, IndexPath)
		case didTapAddButton
	}
	
	// 처리 단위
	enum Mutation {
		case addItem(CategoryHeader)
		case deleteItem(CategoryHeader)
		case dragAndDrop(IndexPath, IndexPath)
		case setNextEditScreen(CategoryHeader?)
		case setNextAddScreen(Bool)
	}
	
	// 현재 상태를 기록
	struct State {
		var addId: Int
		var sections: [CategoryEditSectionModel]
		var nextEditScreen: CategoryHeader?
		var nextAddScreen: Bool = false
		var error = false
	}
	
	// MARK: Properties
	let initialState: State
	let provider: ServiceProviderProtocol

	init(provider: ServiceProviderProtocol, sections: [CategoryEditSectionModel]) {
		self.initialState = State(addId: -(sections.count - 1), sections: sections)
		self.provider = provider
	}
}
//MARK: - Mutate, Reduce
extension CategoryEditUpperReactor {
	/// Action이 들어온 경우, 어떤 처리를 할건지 분기
	func mutate(action: Action) -> Observable<Mutation> {
		switch action {
		case let .dragAndDrop(startIndex, destinationIndexPath):
			return .just(.dragAndDrop(startIndex, destinationIndexPath))
		case .didTapAddButton:
			return .concat([
				.just(.setNextAddScreen(true)),
				.just(.setNextAddScreen(false))
			])
		}
	}
	
	/// 각각의 stream을 변형
	func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
		let event = provider.categoryProvider.event.flatMap { event -> Observable<Mutation> in
			switch event {
			case let .presentUpperEdit(categoryHeader):
				return .concat([
					.just(.setNextEditScreen(categoryHeader)),
					.just(.setNextEditScreen(nil))
				])
			case let .addUpper(categoryHeader):
				return .just(.addItem(categoryHeader))
			case let .deleteUpperEdit(categoryHeader):
				return .just(.deleteItem(categoryHeader))
			default:
				return .empty()
			}
		}
		
		return Observable.merge(mutation, event)
	}
	
	/// 이전 상태와 처리 단위(Mutation)를 받아서 다음 상태(State)를 반환하는 함수
	func reduce(state: State, mutation: Mutation) -> State {
		var newState = state
		
		switch mutation {
		case let .addItem(categoryHeader):
			let item: CategoryEditItem = .base(.init(provider: provider, categoryEdit: CategoryEdit.getDummy())) // 임시
			let model: CategoryEditSectionModel = .init(model: .base(categoryHeader, [item]), items: [item])
			newState.sections.append(model)
			newState.addId -= 1 // 고유값 유지
		case let .deleteItem(deleteItem):
			if let removeIndex = newState.sections.firstIndex(where: { $0.model.header.id == deleteItem.id }) {
				newState.sections.remove(at: removeIndex)
			}
		case let .dragAndDrop(sourceIndexPath, destinationIndexPath):
			let sourceItem = newState.sections[sourceIndexPath.section].items[sourceIndexPath.row]
			newState.sections[sourceIndexPath.section].items.remove(at: sourceIndexPath.row)
			newState.sections[destinationIndexPath.section].items.insert(sourceItem, at: destinationIndexPath.row)
		case let .setNextEditScreen(categoryHeader):
			newState.nextEditScreen = categoryHeader
		case let .setNextAddScreen(categoryHeader):
			newState.nextAddScreen = categoryHeader
		}
		
		return newState
	}
}
