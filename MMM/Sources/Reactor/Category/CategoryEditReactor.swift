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
		case didTapAddButton(CategoryHeader) // 카테고리 추가
		case didTapUpperEditButton // 카테고리 유형 편집
		case dragAndDrop(IndexPath, IndexPath)
	}
	
	// 처리 단위
	enum Mutation {
		case setHeaders([CategoryHeader])
		case setSections([CategoryEditSectionModel])
		case addItem(CategoryEdit)
		case deleteItem(CategoryEdit)
		case dragAndDrop(IndexPath, IndexPath)
		case setNextEditScreen(CategoryEdit?)
		case setNextAddScreen(CategoryHeader?)
		case setNextUpperEditScreen(Bool)
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
		var nextUpperEditScreen: Bool = false
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
			return .concat([
				.just(.setNextAddScreen(categoryHeader)),
				.just(.setNextAddScreen(nil))
			])
		case .didTapUpperEditButton:
			return .concat([
				.just(.setNextUpperEditScreen(true)),
				.just(.setNextUpperEditScreen(false))
			])
		case let .dragAndDrop(startIndex, destinationIndexPath):
			return .just(.dragAndDrop(startIndex, destinationIndexPath))
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
			case let .addCategory(categoryEdit):
				return .just(.addItem(categoryEdit))
			case let .deleteTitleEdit(categoryEdit):
				return .just(.deleteItem(categoryEdit))
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
		case let .setHeaders(headers):
			newState.addId = -headers.count
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
			if let section = newState.sections.enumerated().filter({ $0.element.model.header.id == categoryEdit.upperId }).first {
				let sectionId = section.offset
				
				if let removeIndex = newState.sections[sectionId].items.firstIndex(where: {$0.item.id == categoryEdit.id}) {
					newState.sections[sectionId].items.remove(at: removeIndex)
				}
			}
		case let .dragAndDrop(sourceIndexPath, destinationIndexPath):
			let sourceItem = newState.sections[sourceIndexPath.section].items[sourceIndexPath.row]
			newState.sections[sourceIndexPath.section].items.remove(at: sourceIndexPath.row)
			newState.sections[destinationIndexPath.section].items.insert(sourceItem, at: destinationIndexPath.row)
		case let .setNextEditScreen(categoryEdit):
			newState.nextEditScreen = categoryEdit
		case let .setNextAddScreen(categoryHeader):
			newState.nextAddScreen = categoryHeader
		case let .setNextUpperEditScreen(isNext):
			newState.nextUpperEditScreen = isNext
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

		// Global Header
		let headerItem: CategoryEditItem = .header(.init(provider: provider, categoryEdit: CategoryEdit.getDummy()))
		let headerModel: CategoryEditSectionModel = .init(model: .header(headerItem), items: [headerItem])
		sections.append(headerModel)
		
		for header in currentState.headers {
			let categoryitems: [CategoryEditItem] = data.filter { $0.upperId == header.id }.map { categoryEdit -> CategoryEditItem in
				return .base(.init(provider: provider, categoryEdit: categoryEdit))
			}
			
			let model: CategoryEditSectionModel = .init(model: .base(header, categoryitems), items: categoryitems)
			sections.append(model)
		}
		
		// Global Footer
		let footerItem: CategoryEditItem = .footer(.init(provider: provider, categoryEdit: CategoryEdit.getDummy()))
		let footerModel: CategoryEditSectionModel = .init(model: .footer(footerItem), items: [footerItem])
		sections.append(footerModel)
		
		return sections
	}
}
