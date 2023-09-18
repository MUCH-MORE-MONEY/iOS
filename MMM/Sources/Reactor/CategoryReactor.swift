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
		case setPaySections([CategorySectionModel])
	}
	
	// 현재 상태를 기록
	struct State {
		var paySections: [CategorySectionModel] = []
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
				loadData(CategoryReqDto(economicActivityDvcd: "02"))
			])
		case .fetch, .selectCell:
			return .empty()
		}
	}
	
	/// 이전 상태와 처리 단위(Mutation)를 받아서 다음 상태(State)를 반환하는 함수
	func reduce(state: State, mutation: Mutation) -> State {
		var newState = state
		
		switch mutation {
		case .setPaySections(let sections):
			newState.paySections = sections
		}
		
		return newState
	}
}
//MARK: - Actions
extension CategoryReactor {
	// 데이터 가져오기
	private func loadData(_ request: CategoryReqDto) -> Observable<Mutation> {
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
		
		let categoryitems: [CategoryItem] = data.map { categorty -> CategoryItem in
			return .base(.init(category: categorty))
		}
		
		let firstSectionModel: CategorySectionModel = .init(model: .base(categoryitems), items: categoryitems)

		return [firstSectionModel]
	}
}
