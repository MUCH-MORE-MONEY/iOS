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
		case selectCell(IndexPath, CategoryItem)
	}
	
	// 처리 단위
	enum Mutation {
		case setPayHeaders([CategoryHeader])
		case setEarnHeaders([CategoryHeader])
		case setPaySections([CategorySectionModel])
		case setEarnSections([CategorySectionModel])
		case setNextScreen(Category)
	}
	
	// 현재 상태를 기록
	struct State {
		var date: Date
		var payHeaders: [CategoryHeader] = []
		var earnHeaders: [CategoryHeader] = []
		var paySections: [CategorySectionModel] = []
		var earnSections: [CategorySectionModel] = []
		var nextScreen: Category?
		var error = false
	}
	
	// MARK: Properties
	let initialState: State
	
	init(date: Date) {
		initialState = State(date: date)
		
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
				loadHeaderData(CategoryReqDto(economicActivityDvcd: "01")),
				loadCategoryData(CategoryReqDto(economicActivityDvcd: "01")),
				loadHeaderData(CategoryReqDto(economicActivityDvcd: "02")),
				loadCategoryData(CategoryReqDto(economicActivityDvcd: "02"))
			])
		case .selectCell(_, let categoryItem):
			switch categoryItem {
			case .base(let reactor):
				return .concat([
					.just(.setNextScreen(reactor.currentState.category))
				])
			}
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
		case .setEarnHeaders(let headers):
			newState.earnHeaders = headers
		case .setEarnSections(let sections):
			newState.earnSections = sections
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
		return MMMAPIService().getCategoryEditHeader(request)
			.map { (response, error) -> Mutation in
				if request.economicActivityDvcd == "01" { // 지출
					return .setPayHeaders(response.data.selectListUpperOutputDto)
				} else { // 수입
					return .setEarnHeaders(response.data.selectListUpperOutputDto)
				}
			}
	}
	
	// 데이터 가져오기
	private func loadCategoryData(_ request: CategoryReqDto) -> Observable<Mutation> {
		return MMMAPIService().getCategoryEdit(request)
			.map { [weak self] (response, error) -> Mutation in
				guard let self = self else {
					return .setPaySections([])
				}

				if request.economicActivityDvcd == "01" { // 지출
					return .setPaySections(makeSections(respose: response, type: "01"))
				} else { // 수입
					return .setEarnSections(makeSections(respose: response, type: "02"))
				}
			}
	}
	
	// Section에 따른 Data 주입
	private func makeSections(respose: CategoryEditResDto, type: String) -> [CategorySectionModel] {
		var data = respose.data.selectListOutputDto
		
		if data.isEmpty { // 임시
			data = [Category.getDummy()]
		}
		
		var sections: [CategorySectionModel] = []

		for header in type == "01" ? currentState.payHeaders : currentState.earnHeaders {
			let categoryitems: [CategoryItem] = data.filter { $0.upperOrderNum == header.id }.map { category -> CategoryItem in
				return .base(.init(category: category))
			}
			
			let model: CategorySectionModel = .init(model: .base(header, categoryitems), items: categoryitems)
			sections.append(model)
		}

		return sections
	}
}
