//
//  CategoryEditReactor.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/24.
//

import ReactorKit

final class CategoryEditReactor: Reactor {
	// 사용자의 액션
	enum Action {
		case loadData(String)
		case didTapAddButton(CategoryHeader)
		case dragAndDrop(IndexPath, IndexPath, CategoryEditItem)
	}
	
	// 처리 단위
	enum Mutation {
		case setHeaders([CategoryHeader])
		case setSections([CategoryEditSectionModel])
		case addItem(CategoryEdit)
		case deleteItem(CategoryEdit)
		case dragAndDrop(IndexPath, IndexPath, CategoryEditItem)
		case setNextEditScreen(CategoryEdit?)
		case setNextAddScreen(CategoryHeader)
	}
	
	// 현재 상태를 기록
	struct State {
		var addId: Int = 0
		var type: String
		var date: Date
		var headers: [CategoryHeader] = []
		var sections: [CategoryEditSectionModel] = []
		var nextEditScreen: CategoryEdit?
		var nextAddScreen: CategoryHeader?
		var error = false
	}
	
	// MARK: Properties
	let initialState: State
	let provider: ServiceProviderProtocol

	init(provider: ServiceProviderProtocol, type: String, date: Date) {
		self.initialState = State(type: type, date: date)
		self.provider = provider

		// 뷰가 최초 로드 될 경우
		action.onNext(.loadData(type))
	}
}
//MARK: - Mutate, Reduce
extension CategoryEditReactor {
	/// Action이 들어온 경우, 어떤 처리를 할건지 분기
	func mutate(action: Action) -> Observable<Mutation> {
		switch action {
		case let .loadData(type):
			return .concat([
				loadHeaderData(CategoryEditReqDto(economicActivityDvcd: type)),
				loadCategoryData(CategoryEditReqDto(economicActivityDvcd: type))
			])
		case let .didTapAddButton(categoryHeader):
			return .just(.setNextAddScreen(categoryHeader))
		case let .dragAndDrop(startIndex, destinationIndexPath, item):
			return .just(.dragAndDrop(startIndex, destinationIndexPath, item))
		}
	}
	
	/// 각각의 stream을 변형
	func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
		let event = provider.categoryProvider.event.flatMap { event -> Observable<Mutation> in
			switch event {
			case let .presentTitleEdit(categoryEdit):
				return .concat([
					.just(.setNextEditScreen(categoryEdit)),
					.just(.setNextEditScreen(nil))
				])
			case .updateTitleEdit:
				return .empty()
			case let .addCategory(categoryEdit):
				return .just(.addItem(categoryEdit))
			case let .deleteTitleEdit(categoryEdit):
				return .just(.deleteItem(categoryEdit))
			}
		}
		
		return Observable.merge(mutation, event)
	}
	
	/// 이전 상태와 처리 단위(Mutation)를 받아서 다음 상태(State)를 반환하는 함수
	func reduce(state: State, mutation: Mutation) -> State {
		var newState = state
		
		switch mutation {
		case let .setHeaders(headers):
			newState.headers = headers
		case let .setSections(sections):
			newState.sections = sections
		case let .addItem(categoryEdit):
			if let section = newState.sections.enumerated().filter({ $0.element.model.header.id == categoryEdit.upperId }).first {
				let sectionId = section.offset
				
				var newItem = categoryEdit
				newItem.orderNum = newState.sections[sectionId].items.count + 1
				let categoryEditItem: CategoryEditItem = .base(.init(provider: provider, categoryEdit: newItem))
				newState.sections[sectionId].items.append(categoryEditItem) // 해당 Sections을 찾아서 append
				newState.addId -= 1 // 1씩 감소 시키면서 고유한 값 유지
			}
		case let .deleteItem(categoryEdit):
			guard let sectionId = Int(categoryEdit.upperId) else {
				return newState
			}
			
			if let removeIndex = newState.sections[sectionId - 1].items.firstIndex(where: {$0.item.id == categoryEdit.id}) {
				newState.sections[sectionId - 1].items.remove(at: removeIndex)
			}
		case let .dragAndDrop(startIndex, destinationIndexPath, item):
			var sections = newState.sections
			
			sections[startIndex.section].items.remove(at: startIndex.row)
			sections[startIndex.section].items.insert(item, at: destinationIndexPath.row)
			newState.sections = sections
//			let temp = newState.sections[startIndex.section].items[startIndex.row].item.orderNum
//			newState.sections[startIndex.section].items[startIndex.row].item.orderNum = newState.sections[startIndex.section].items[destinationIndexPath.row].item.orderNum
//			for item in newState.sections[destinationIndexPath.section].items {
//				print(item.item)
//			}
		case let .setNextEditScreen(categoryEdit):
			newState.nextEditScreen = categoryEdit
		case let .setNextAddScreen(categoryHeader):
			newState.nextAddScreen = categoryHeader
		}
		
		return newState
	}
}
//MARK: - Action
extension CategoryEditReactor {
	// 데이터 Header 가져오기
	private func loadHeaderData(_ request: CategoryEditReqDto) -> Observable<Mutation> {
		return MMMAPIService().getCategoryEditHeader(request)
			.map { (response, error) -> Mutation in
				return .setHeaders(response.data.selectListUpperOutputDto)
			}
	}
	
	// 데이터 가져오기
	private func loadCategoryData(_ request: CategoryEditReqDto) -> Observable<Mutation> {
		return MMMAPIService().getCategoryEdit(request)
			.map { (response, error) -> Mutation in
				return .setSections(self.makeSections(respose: response, type: request.economicActivityDvcd))
			}
	}
	
	// Section에 따른 Data 주입
	private func makeSections(respose: CategoryEditResDto, type: String) -> [CategoryEditSectionModel] {
		let data = respose.data.selectListOutputDto

		var sections: [CategoryEditSectionModel] = []

		for header in currentState.headers {
			let categoryitems: [CategoryEditItem] = data.filter { $0.upperId == header.id }.map { categoryEdit -> CategoryEditItem in
				return .base(.init(provider: provider, categoryEdit: categoryEdit))
			}
			
			let model: CategoryEditSectionModel = .init(model: .base(header, categoryitems), items: categoryitems)
			sections.append(model)
		}

		return sections
	}
}
