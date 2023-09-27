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
		case dragAndDrop(IndexPath, IndexPath, CategoryEditItem)
	}
	
	// 처리 단위
	enum Mutation {
		case setHeaders([CategoryHeader])
		case setSections([CategoryEditSectionModel])
		case dragAndDrop(IndexPath, IndexPath, CategoryEditItem)
		case setNextEditScreen(CategoryEdit)
	}
	
	// 현재 상태를 기록
	struct State {
		var type: String
		var date: Date
		var headers: [CategoryHeader] = []
		var sections: [CategoryEditSectionModel] = []
		var nextEditScreen: CategoryEdit?
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
		case let .dragAndDrop(startIndex, destinationIndexPath, item):
			return .just(.dragAndDrop(startIndex, destinationIndexPath, item))
		}
	}
	
	/// 각각의 stream을 변형
	func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
		let event = provider.categoryProvider.event.flatMap { event -> Observable<Mutation> in
			switch event {
			case let .presentTitleEdit(categoryEdit):
				return .just(.setNextEditScreen(categoryEdit))
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
			let categoryitems: [CategoryEditItem] = data.filter { $0.upperOrderNum == header.id }.map { categoryEdit -> CategoryEditItem in
				return .base(.init(provider: provider, categoryEdit: categoryEdit))
			}
			
			let model: CategoryEditSectionModel = .init(model: .base(header, categoryitems), items: categoryitems)
			sections.append(model)
		}

		return sections
	}
}
