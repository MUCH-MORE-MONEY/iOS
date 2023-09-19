//
//  WithdrawReactor.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/19.
//

import ReactorKit

final class WithdrawReactor: Reactor {
	// 사용자의 액션
	enum Action {
		case loadData
		case tapWithdraw
	}
	
	// 처리 단위
	enum Mutation {
		case setSummary(Summary)
		case withdraw
		case setLoading(Bool)
		case setError(Bool)
	}
	
	// 현재 상태를 기록
	struct State {
		var summary: Summary?
		var isLoading = false // 로딩
		var error = false
	}
	
	struct Summary: Equatable {
		var recordCnt: Int
		var recordSumAmount: Int
	}
	
	// MARK: Properties
	let initialState: State
	
	// 초기 State 설정
	init() {
		initialState = State()
		
		// 뷰가 최초 로드 될 경우
		action.onNext(.loadData)
	}
}
//MARK: - Mutate, Reduce
extension WithdrawReactor {
	/// Action이 들어온 경우, 어떤 처리를 할건지 분기
	func mutate(action: Action) -> Observable<Mutation> {
		switch action {
		case .loadData:
			return .concat([
				.just(.setLoading(true)),
				getSummary(),
				.just(.setLoading(false))
			])
		case .tapWithdraw:
			return .concat([
				.just(.setLoading(true)),
				withdraw(),
				.just(.setLoading(false))
			])
		}
	}
	
	/// 이전 상태와 처리 단위(Mutation)를 받아서 다음 상태(State)를 반환하는 함수
	func reduce(state: State, mutation: Mutation) -> State {
		var newState = state
		
		switch mutation {
		case .setSummary(let summary):
			newState.summary = summary
		case .withdraw:
			// 사용자 모든 정보 제거
			Constants.removeAllKeychain()
		case .setLoading(let isLoading):
			newState.isLoading = isLoading
		case .setError(let isError):
			newState.error = isError
		}
		
		return newState
	}
}
//MARK: - Action
extension WithdrawReactor {
	/// 데이터 가져오기
	private func getSummary() -> Observable<Mutation> {
		return MMMAPIService().getSummary()
			.map { (response, error) -> Mutation in
				if error != nil {
					return .setError(true)
				} else {
					return .setSummary(Summary(recordCnt: response.economicActivityTotalCnt, recordSumAmount: response.economicActivitySumAmt))
				}
			}
	}
	
	/// 탈퇴 내보내기
	private func withdraw() -> Observable<Mutation> {
		return MMMAPIService().withdraw()
			.map { (response, error) -> Mutation in
				if error != nil {
					return .setError(true)
				} else {
					return .withdraw
				}
			}
	}
}
