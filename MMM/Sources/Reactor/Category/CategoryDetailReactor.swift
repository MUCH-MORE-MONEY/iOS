//
//  CategoryDetailReactor.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/23.
//

import ReactorKit

final class CategoryDetailReactor: Reactor {
	// 사용자의 액션
	enum Action {
		case loadData
		case selectCell(IndexPath, CategoryDetailItem)
	}
	
	// 처리 단위
	enum Mutation {
		case setList([EconomicActivity])
		case pushDetail(IndexPath, EconomicActivity, Bool)
		case setLoading(Bool)
		case setError
	}
	
	// 현재 상태를 기록
	struct State {
		var date: Date
		var type: String
		var section: Category
		var categoryLowwer: CategoryLowwer
		var list: [CategoryDetailSectionModel] = [.init(model: "", items: CategoryDetailItem.getSkeleton())]
		var detailData: (IndexPath: IndexPath, info: EconomicActivity)?
		var isPushDetail = false
		var isLoading = true // 로딩
		var error = false
	}
	
	// MARK: Properties
	let initialState: State
	
	init(date: Date, type: String, section: Category, categoryLowwer: CategoryLowwer) {
		
		initialState = State(date: date, type: type, section: section, categoryLowwer: categoryLowwer)
		
		// 뷰가 최초 로드 될 경우
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
			guard let self = self else { return }
			action.onNext(.loadData)
		}
	}
}
//MARK: - Mutate, Reduce
extension CategoryDetailReactor {
	/// Action이 들어온 경우, 어떤 처리를 할건지 분기
	func mutate(action: Action) -> Observable<Mutation> {
		switch action {
		case .loadData:
			let category = currentState.categoryLowwer
			return .concat([
				.just(.setLoading(true)),
				loadData(CategoryDetailListReqDto(dateYM: currentState.date.getFormattedYM(), economicActivityCategoryCd: category.id, economicActivityDvcd: currentState.type)),
				.just(.setLoading(false))
			])
		case let .selectCell(indexPath, data):
			guard let item = data.item else { return .empty() }
			
			return .concat([
				.just(.pushDetail(indexPath, item, true)),
				.just(.pushDetail(indexPath, item, false))
			])
		}
	}
	
	/// 이전 상태와 처리 단위(Mutation)를 받아서 다음 상태(State)를 반환하는 함수
	func reduce(state: State, mutation: Mutation) -> State {
		var newState = state
		
		switch mutation {
		case .setList(let economicActivityList):
			// 비어 있지 않을 경우에만 처리
			guard !economicActivityList.isEmpty else {
				newState.list = []
				return newState
			}
			
			let items = economicActivityList.map { category -> CategoryDetailItem in
				return .base(category)
			}
			let model: CategoryDetailSectionModel = .init(model: "", items: items)
			
			newState.list = [model]
		case .pushDetail(let indexPath, let data, let isPush):
			newState.detailData = (indexPath, data)
			newState.isPushDetail = isPush
		case let .setLoading(isLoading):
			newState.isLoading = isLoading
		case .setError:
			newState.isLoading = false
		}
		
		return newState
	}
}
//MARK: - Action
extension CategoryDetailReactor {
	// 데이터 가져오기
	private func loadData(_ request: CategoryDetailListReqDto) -> Observable<Mutation> {
		return MMMAPIService().getCategoryDetailList(request)
			.map { (response, error) -> Mutation in
				return .setList(response.data.selectListMonthlyByCategoryCdOutputDto)
			}
			.catchAndReturn(.setError)
	}
}
