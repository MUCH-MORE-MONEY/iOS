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
		case refresh
		case selectCell(IndexPath, CategoryMainItem)
	}
	
	// 처리 단위
	enum Mutation {
		case setPaySections([CategoryMainSectionModel])
		case setEarnSections([CategoryMainSectionModel])
		case setNextScreen(IndexPath, CategoryLowwer?)
		case setRefresh(Bool)
		case setLoading(Bool)
		case setError
	}
	
	// 현재 상태를 기록
	struct State {
		var date: Date
		var paySections: [CategoryMainSectionModel] = [CategoryMainSectionModel(model: .init(original: .header(.header), items: []), items: [])]
		var earnSections: [CategoryMainSectionModel] = [CategoryMainSectionModel(model: .init(original: .header(.header), items: []), items: [])]
		var indexPath: IndexPath?
		var nextScreen: CategoryLowwer?
		var isLoading = false // 로딩
		var isRrefresh = false // 편집후 저장할 때만
		var error = false
	}
	
	// MARK: Properties
	let initialState: State
	let provider: ServiceProviderProtocol

	init(provider: ServiceProviderProtocol, date: Date) {
		self.initialState = State(date: date)
		self.provider = provider

		// 뷰가 최초 로드 될 경우
		action.onNext(.loadData)
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
				.just(.setLoading(true)),
				loadData(CategoryDetailListReqDto(dateYM: dateYM, economicActivityCategoryCd: "", economicActivityDvcd: "01")),
				loadData(CategoryDetailListReqDto(dateYM: dateYM, economicActivityCategoryCd: "", economicActivityDvcd: "02")),
				.just(.setLoading(false))
			])
		case .refresh:
			// ViewWillAppear시, 편집 단계에서 저장을 했는지 여부에 따른 수행
			if currentState.isRrefresh {
				let dateYM = currentState.date.getFormattedYM()

				return .concat([
					.just(.setLoading(true)),
					loadData(CategoryDetailListReqDto(dateYM: dateYM, economicActivityCategoryCd: "", economicActivityDvcd: "01")),
					loadData(CategoryDetailListReqDto(dateYM: dateYM, economicActivityCategoryCd: "", economicActivityDvcd: "02")),
					.just(.setRefresh(false)), // 다시 refresh 돌리기
					.just(.setLoading(false))
				])
			} else {
				return .empty()
			}
		case let .selectCell(indexPath, categoryItem):
			switch categoryItem {
			case let .base(reactor):
				return .concat([
					.just(.setNextScreen(indexPath, reactor.currentState.categoryLowwer)),
					.just(.setNextScreen(indexPath, nil))
				])
			case .header, .empty:
				return .empty()
			}
		}
	}
	
	/// 각각의 stream을 변형
	func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
		let event = provider.categoryProvider.event.flatMap { event -> Observable<Mutation> in
			switch event {
			case let .refresh(isRefresh): 	return .just(.setRefresh(isRefresh))
			default: 						return .empty()
			}
		}
		
		return Observable.merge(mutation, event)
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
		case let .setRefresh(isRefresh):
			newState.isRrefresh = isRefresh
		case let .setLoading(isLoading):
			newState.isLoading = isLoading
		case .setError:
			newState.isLoading = false
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
			.catchAndReturn(.setError)
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
			var categoryitems: [CategoryMainItem] = category.lowwer.map { categoryLowwer -> CategoryMainItem in
				return .base(.init(categoryLowwer: categoryLowwer))
			}
			
			// 비어 있을 경우
			if categoryitems.isEmpty { categoryitems.append(.empty) }
			
			let model: CategoryMainSectionModel = .init(model: .base(category, categoryitems), items: categoryitems)
			sections.append(model)
		}

		return sections
	}
}
