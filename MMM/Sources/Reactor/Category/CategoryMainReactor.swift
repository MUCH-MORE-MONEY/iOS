//
//  CategoryMainReactor.swift
//  MMM
//
//  Created by geonhyeong on 2023/08/23.
//

import ReactorKit

final class CategoryMainReactor: Reactor {
	// 사용자의 액션
	enum Action {
		case loadData
		case selectCell(IndexPath, CategoryMainItem)
	}
	
	// 처리 단위
	enum Mutation {
		case setPaySections([CategoryMainSectionModel])
		case setEarnSections([CategoryMainSectionModel])
		case setNextScreen(IndexPath, CategoryLowwer?)
	}
	
	// 현재 상태를 기록
	struct State {
		var date: Date
		var paySections: [CategoryMainSectionModel] = [CategoryMainSectionModel(model: .init(original: .header(.header), items: []), items: [])]
		var earnSections: [CategoryMainSectionModel] = [CategoryMainSectionModel(model: .init(original: .header(.header), items: []), items: [])]
		var indexPath: IndexPath?
		var nextScreen: CategoryLowwer?
		var error = false
	}
	
	// MARK: Properties
	let initialState: State
	
	init(date: Date) {
		initialState = State(date: date)
	}
}
//MARK: - Mutate, Reduce
extension CategoryMainReactor {
	/// Action이 들어온 경우, 어떤 처리를 할건지 분기
	func mutate(action: Action) -> Observable<Mutation> {
		switch action {
		case .loadData:
			let dateYM = currentState.date.getFormattedYM()
			
			return .concat([
				loadData(CategoryDetailListReqDto(dateYM: dateYM, economicActivityCategoryCd: "", economicActivityDvcd: "01")),
				loadData(CategoryDetailListReqDto(dateYM: dateYM, economicActivityCategoryCd: "", economicActivityDvcd: "02"))
			])
		case let .selectCell(indexPath, categoryItem):
			switch categoryItem {
			case .base(let reactor):
				return .concat([
					.just(.setNextScreen(indexPath, reactor.currentState.categoryLowwer)),
					.just(.setNextScreen(indexPath, nil))
				])
			case .header:
				return .empty()
			}
		}
	}
	
	/// 이전 상태와 처리 단위(Mutation)를 받아서 다음 상태(State)를 반환하는 함수
	func reduce(state: State, mutation: Mutation) -> State {
		var newState = state
		
		switch mutation {
		case let .setPaySections(sections):
			newState.paySections = sections
		case let .setEarnSections(sections):
			newState.earnSections = sections
		case let .setNextScreen(indexPath, nextScreen):
			newState.indexPath = indexPath
			newState.nextScreen = nextScreen
		}
		
		return newState
	}
}
//MARK: - Action
extension CategoryMainReactor {
	// 데이터 가져오기
	private func loadData(_ request: CategoryDetailListReqDto) -> Observable<Mutation> {
		return MMMAPIService().getCategoryList(request)
			.map { (response, error) -> Mutation in
				if request.economicActivityDvcd == "01" { // 지출
					return .setPaySections(self.makeSections(respose: response, type: "01"))
				} else { // 수입
					return .setEarnSections(self.makeSections(respose: response, type: "02"))
				}
			}
	}

	// Section에 따른 Data 주입
	private func makeSections(respose: CategoryListResDto, type: String) -> [CategoryMainSectionModel] {
		let categoryList = respose.data
		var sections: [CategoryMainSectionModel] = []

		// Global Header
		let headerItem: CategoryMainItem = .header
		let headerModel: CategoryMainSectionModel = .init(model: .header(headerItem), items: [headerItem])
		sections.append(headerModel)

		for category in categoryList {
			let categoryitems: [CategoryMainItem] = category.lowwer.map { categoryLowwer -> CategoryMainItem in
				return .base(.init(categoryLowwer: categoryLowwer))
			}
			
			let model: CategoryMainSectionModel = .init(model: .base(category, categoryitems), items: categoryitems)
			sections.append(model)
		}

		return sections
	}
}
