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
		case didTabSaveButton
		case dragAndDrop(IndexPath, IndexPath)
		case didTapAddButton
	}
	
	// 처리 단위
	enum Mutation {
		case editItem(CategoryHeader)
		case addItem(CategoryHeader)
		case deleteItem(CategoryHeader)
		case dragAndDrop(IndexPath, IndexPath)
		case setNextEditScreen(CategoryHeader?)
		case setNextAddScreen(Bool)
		case dismiss
	}
	
	// 현재 상태를 기록
	struct State {
		var addId: Int
		var sections: [CategoryEditSectionModel]
		var nextEditScreen: CategoryHeader?
		var nextAddScreen: Bool = false
		var dismiss = false
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
		case .didTabSaveButton:
			return provider.categoryProvider.saveSections(to: currentState.sections).map { _ in .dismiss }
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
			case let .updateUpperEdit(categoryHeader):
				return .just(.editItem(categoryHeader))
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
		case let .editItem(categoryHeader):
			if let editIndex = newState.sections.firstIndex(where: { $0.model.header.id == categoryHeader.id }) {
				// 수정이 되지 않아 직접 삭제 후, insert
				var data = newState.sections.remove(at: editIndex)
				let model: CategoryEditSectionModel = .init(model: .base(categoryHeader, data.items), items: data.items)
				newState.sections.insert(model, at: editIndex)
			}
		case let .addItem(categoryHeader):
			let item: CategoryEditItem = .base(.init(provider: provider, categoryEdit: CategoryEdit.getDummy())) // 임시
			let model: CategoryEditSectionModel = .init(model: .base(categoryHeader, [item]), items: [item])
			let grobalFooter = newState.sections.removeLast()
			newState.sections.append(model)
			newState.addId -= 1 // 고유값 유지
			newState.sections.append(grobalFooter)
		case let .deleteItem(categoryHeader):
			if let removeIndex = newState.sections.firstIndex(where: { $0.model.header.id == categoryHeader.id }) {
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
		case .dismiss:
			newState.dismiss = true
		}
		
		return newState
	}
}
