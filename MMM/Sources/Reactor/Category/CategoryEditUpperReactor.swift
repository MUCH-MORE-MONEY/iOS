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
		case didTabBackButton
		case dragAndDrop(IndexPath, IndexPath)
		case didTapAddButton
	}
	
	// 처리 단위
	enum Mutation {
		case editItem(CategoryHeader)
		case addItem(CategoryHeader)
		case deleteItem(CategoryHeader)
		case dragAndDrop(IndexPath, IndexPath)
		case setSave(Bool)
		case setPresentAlert(Bool)
		case setNextEditScreen(CategoryHeader?)
		case setNextAddScreen(Bool)
		case dismiss
	}
	
	// 현재 상태를 기록
	struct State {
		var addId: Int
		var preSections: [CategoryEditSectionModel]
		var sections: [CategoryEditSectionModel]
		var removedUpperCategory: [String:String] = [:] // id:title
		var isReloadData = true
		var isEdit: Bool = false
		var nextEditScreen: CategoryHeader?
		var nextAddScreen: Bool = false
		var isSave: Bool = false
		var dismiss = false
		var error = false
	}
	
	// MARK: Properties
	let initialState: State
	let provider: ServiceProviderProtocol

	init(provider: ServiceProviderProtocol, sections: [CategoryEditSectionModel]) {
		self.initialState = State(addId: -(sections.count - 1), preSections: sections, sections: sections)
		self.provider = provider
	}
}
//MARK: - Mutate, Reduce
extension CategoryEditUpperReactor {
	/// Action이 들어온 경우, 어떤 처리를 할건지 분기
	func mutate(action: Action) -> Observable<Mutation> {
		switch action {
		case .didTabSaveButton:
			return Observable.zip(provider.categoryProvider.saveSections(to: currentState.sections), provider.categoryProvider.deleteList(to: currentState.removedUpperCategory))
				.map { _ in .setSave(true) }
		case .didTabBackButton:	// 수정이 되었는지 판별
			return .concat([
				.just(.setPresentAlert(true)),
				.just(.setPresentAlert(false))
			])
		case let .dragAndDrop(startIndex, destinationIndexPath):
			return .concat([
				.just(.dragAndDrop(startIndex, destinationIndexPath))
			])
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
				let data = newState.sections.remove(at: editIndex)
				let model: CategoryEditSectionModel = .init(model: .base(categoryHeader, data.items), items: data.items)
				newState.sections.insert(model, at: editIndex)
			}
		case let .addItem(categoryHeader):
			let item: CategoryEditItem = .empty // 빈 Cell 넣어주기
			let model: CategoryEditSectionModel = .init(model: .base(categoryHeader, [item]), items: [item])
			newState.sections.append(model)
			newState.addId -= 1 // 고유값 유지
		case let .deleteItem(categoryHeader):
			if let removeIndex = newState.sections.firstIndex(where: { $0.model.header.id == categoryHeader.id }) {
				// 삭제된 카테고리 저장
				newState.removedUpperCategory[categoryHeader.id] = categoryHeader.title
				
				newState.sections.remove(at: removeIndex)
			}
		case let .dragAndDrop(sourceIndexPath, destinationIndexPath):
			let sourceItem = newState.sections[sourceIndexPath.row + 1]
			newState.sections.remove(at: sourceIndexPath.row + 1)
			newState.sections.insert(sourceItem, at: destinationIndexPath.row + 1)
			newState.isReloadData = false
		case let .setSave(isSave):
			newState.isSave = isSave
		case let .setPresentAlert(isAlert): // 수정되었는지 판별
			if isAlert {
				let isEdit = self.transformData(input: newState.preSections) == self.transformData(input: newState.sections)
				newState.isEdit = !isEdit
				
				if isEdit { newState.dismiss = true }
			} else {
				newState.isEdit = false
			}
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
//MARK: - Action
extension CategoryEditUpperReactor {
	// 비교를 위한 데이터 변환
	private func transformData(input: [CategoryEditSectionModel]) -> [CategoryHeader] {
		guard 1 < input.count else { return [] }
		
		return input[1..<input.count - 1].map { section -> CategoryHeader in
			let id = section.model.header.id
			let title = section.model.header.title
			return .init(id: id, title: title, orderNum: 0)
		}
	}
}
