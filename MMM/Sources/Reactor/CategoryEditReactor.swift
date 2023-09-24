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
	}
	
	// 처리 단위
	enum Mutation {
		case setHeaders([CategoryHeader])
		case setSections([CategoryEditSectionModel])
	}
	
	// 현재 상태를 기록
	struct State {
		var type: String
		var date: Date
		var headers: [CategoryHeader] = []
		var sections: [CategoryEditSectionModel] = []
		var error = false
	}
	
	// MARK: Properties
	let initialState: State
	
	init(type: String, date: Date) {
		initialState = State(type: type, date: date)
		
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
				loadHeaderData(CategoryReqDto(economicActivityDvcd: type)),
				loadCategoryData(CategoryReqDto(economicActivityDvcd: type))
			])
		}
	}
	
	/// 이전 상태와 처리 단위(Mutation)를 받아서 다음 상태(State)를 반환하는 함수
	func reduce(state: State, mutation: Mutation) -> State {
		var newState = state
		
		switch mutation {
		case .setHeaders(let headers):
			newState.headers = headers
		case .setSections(let sections):
			newState.sections = sections
		}
		
		return newState
	}
}
//MARK: - Action
extension CategoryEditReactor {
	// 데이터 Header 가져오기
	private func loadHeaderData(_ request: CategoryReqDto) -> Observable<Mutation> {
		return MMMAPIService().getCategoryHeader(request)
			.map { (response, error) -> Mutation in
				return .setHeaders(response.data.selectListUpperOutputDto)
			}
	}
	
	// 데이터 가져오기
	private func loadCategoryData(_ request: CategoryReqDto) -> Observable<Mutation> {
		return MMMAPIService().getCategory(request)
			.map { (response, error) -> Mutation in
				return .setSections(self.makeSections(respose: response, type: request.economicActivityDvcd))
			}
	}
	
	// Section에 따른 Data 주입
	private func makeSections(respose: CategoryResDto, type: String) -> [CategoryEditSectionModel] {
		var data = respose.data.selectListOutputDto
		
		if data.isEmpty { // 임시
			data = [Category.getDummy()]
		}
		
		var sections: [CategoryEditSectionModel] = []

		for header in currentState.headers {
			let categoryitems: [CategoryEditItem] = data.filter { $0.upperOrderNum == header.id }.map { category -> CategoryEditItem in
				return .base(.init(category: category))
			}
			
			let model: CategoryEditSectionModel = .init(model: .base(header, categoryitems), items: categoryitems)
			sections.append(model)
		}

		return sections
	}
}
