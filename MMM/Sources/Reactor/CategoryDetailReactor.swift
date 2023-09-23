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
		case selectCell(IndexPath, EconomicActivity)
	}
	
	// 처리 단위
	enum Mutation {
		case setList([EconomicActivity])
		case pushDetail(IndexPath, EconomicActivity, Bool)
	}
	
	// 현재 상태를 기록
	struct State {
		var date: Date
		var category: Category
		var list: [EconomicActivity] = []
		var detailData: (IndexPath: IndexPath, info: EconomicActivity)?
		var isPushDetail = false
		var error = false
	}
	
	// MARK: Properties
	let initialState: State
	
	init(date: Date, category: Category) {
		initialState = State(date: date, category: category)
		
		// 뷰가 최초 로드 될 경우
		action.onNext(.loadData)
	}
}
//MARK: - Mutate, Reduce
extension CategoryDetailReactor {
	/// Action이 들어온 경우, 어떤 처리를 할건지 분기
	func mutate(action: Action) -> Observable<Mutation> {
		switch action {
		case .loadData:
			let category = currentState.category
			return .concat([
				loadData(CategoryListReqDto(dateYM: currentState.date.getFormattedYM(), economicActivityCategoryCd: category.id))
			])
		case .selectCell(let indexPath, let data):
			return .concat([
				.just(.pushDetail(indexPath, data, true)),
				.just(.pushDetail(indexPath, data, false))
			])
		}
	}
	
	/// 이전 상태와 처리 단위(Mutation)를 받아서 다음 상태(State)를 반환하는 함수
	func reduce(state: State, mutation: Mutation) -> State {
		var newState = state
		
		switch mutation {
		case .setList(let economicActivityList):
			newState.list = economicActivityList
		case .pushDetail(let indexPath, let data, let isPush):
			newState.detailData = (indexPath, data)
			newState.isPushDetail = isPush
		}
		
		return newState
	}
}
//MARK: - Action
extension CategoryDetailReactor {
	// 데이터 가져오기
	private func loadData(_ request: CategoryListReqDto) -> Observable<Mutation> {
		return MMMAPIService().getCategoryList(request)
			.map { (response, error) -> Mutation in
				return .setList(response.data.selectListMonthlyByCategoryCdOutputDto)
			}
	}
}