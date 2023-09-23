//
//  CategoryReactor.swift
//  MMM
//
//  Created by geonhyeong on 2023/08/23.
//

import ReactorKit

final class CategoryReactor: Reactor {
	// 사용자의 액션
	enum Action {
		case loadData
		case fetch
		case selectCell(IndexPath, CategoryItem)
	}
	
	// 처리 단위
	enum Mutation {
		case setPayHeaders([CategoryHeader])
		case setPaySections([CategorySectionModel])
		case setNextScreen(Bool)
	}
	
	// 현재 상태를 기록
	struct State {
		var payHeaders: [CategoryHeader] = []
		var paySections: [CategorySectionModel] = []
		var nextScreen = false
		var error = false
	}
	
	// MARK: Properties
	let initialState: State
	
	init() {
		initialState = State()
		
		// 뷰가 최초 로드 될 경우
		action.onNext(.loadData)
	}
}
//MARK: - Mutate, Reduce
extension CategoryReactor {
	/// Action이 들어온 경우, 어떤 처리를 할건지 분기
	func mutate(action: Action) -> Observable<Mutation> {
		switch action {
		case .loadData:
			return .concat([
				loadHeaderData(CategoryReqDto(economicActivityDvcd: "02")),
				loadCategoryData(CategoryReqDto(economicActivityDvcd: "02"))
			])
		case .fetch:
			return .empty()
		case .selectCell:
			return .concat([
				.just(.setNextScreen(true)),
				.just(.setNextScreen(false))
			])
		}
	}
	
	/// 이전 상태와 처리 단위(Mutation)를 받아서 다음 상태(State)를 반환하는 함수
	func reduce(state: State, mutation: Mutation) -> State {
		var newState = state
		
		switch mutation {
		case .setPayHeaders(let headers):
			newState.payHeaders = headers
		case .setPaySections(let sections):
			newState.paySections = sections
		case .setNextScreen(let nextScreen):
			newState.nextScreen = nextScreen
		}
		
		return newState
	}
}
//MARK: - Action
extension CategoryReactor {
	// 데이터 Header 가져오기
	private func loadHeaderData(_ request: CategoryReqDto) -> Observable<Mutation> {
		return MMMAPIService().getCategoryHeader(request)
			.map { [weak self] (response, error) -> Mutation in
				guard let self = self else {
					return .setPayHeaders([])
				}

				if request.economicActivityDvcd == "01" { // 수입
					return .setPayHeaders(response.data.selectListUpperOutputDto)
				} else { // 지출
					return .setPayHeaders(response.data.selectListUpperOutputDto)
				}
			}
	}
	
	// 데이터 가져오기
	private func loadCategoryData(_ request: CategoryReqDto) -> Observable<Mutation> {
		return MMMAPIService().getCategory(request)
			.map { [weak self] (response, error) -> Mutation in
				guard let self = self else {
					return .setPaySections([])
				}

				if request.economicActivityDvcd == "01" { // 수입
					return .setPaySections(makeSections(respose: response))
				} else { // 지출
					return .setPaySections(makeSections(respose: response))
				}
			}
	}
	
	// Section에 따른 Data 주입
	private func makeSections(respose: CategoryResDto) -> [CategorySectionModel] {
		var data = respose.data.selectListOutputDto
		
		if data.isEmpty { // 임시
			data = [Category.getDummy()]
		}
		
		var sections: [CategorySectionModel] = []

		for header in currentState.payHeaders {
			let categoryitems: [CategoryItem] = data.filter { $0.upperId == header.id }.map { category -> CategoryItem in
				return .base(.init(category: category))
			}
			
			let model: CategorySectionModel = .init(model: .base(header, categoryitems), items: categoryitems)
			sections.append(model)
		}

		return sections
	}
}
