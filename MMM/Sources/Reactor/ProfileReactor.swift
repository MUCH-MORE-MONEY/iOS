//
//  ProfileReactor.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/19.
//

import ReactorKit

final class ProfileReactor: Reactor {
	// 사용자의 액션
	enum Action {
		case logout
		case export
	}
	
	// 처리 단위
	enum Mutation {
		case logout
		case exportToExcel(File)
		case setLoading(Bool)
		case setError(Bool)
	}
	
	// 현재 상태를 기록
	struct State {
		var userEmail: String?
		var file: File?
		var isLoading = false // 로딩
		var error = false
	}
	
	struct File: Equatable {
		var fileName: String
		var data: Data
	}
	
	// MARK: Properties
	let initialState: State
	
	// 초기 State 설정
	init() {
		// 이메일 가져오기
		guard let email = Constants.getKeychainValue(forKey: Constants.KeychainKey.email) else {
			initialState = State()
			return
		}

		initialState = .init(userEmail: email)
	}
}
//MARK: - Mutate, Reduce
extension ProfileReactor {
	/// Action이 들어온 경우, 어떤 처리를 할건지 분기
	func mutate(action: Action) -> Observable<Mutation> {
		switch action {
		case .logout:
			return .just(.logout)
		case .export:
			return .concat([
				.just(.setLoading(true)),
				exportToExcel(),
				.just(.setLoading(false))
			])
		}
	}
	
	/// 이전 상태와 처리 단위(Mutation)를 받아서 다음 상태(State)를 반환하는 함수
	func reduce(state: State, mutation: Mutation) -> State {
		var newState = state
		
		switch mutation {
		case .logout:
			self.logout()
			newState.userEmail = nil
		case .exportToExcel(let file):
			newState.file = file
		case .setLoading(let isLoading):
			newState.isLoading = isLoading
		case .setError(let isError):
			newState.error = isError
		}
		
		return newState
	}
}
//MARK: - Action
extension ProfileReactor {
	/// 데이터 내보내기
	private func exportToExcel() -> Observable<Mutation> {
		return MMMAPIService().exportToExcel()
			.map { (response, error) -> Mutation in
				guard let data = Data(base64Encoded: response.binaryData) else {
					return .setError(true)
				}
				
				if let onError = error {
					return .setError(true)
				} else {
					return .exportToExcel(File(fileName: response.fileNm, data: data))
				}
			}
	}
	
	/// 로그아웃 - remove Keychain
	func logout() {
		Constants.removeKeychain(forKey: Constants.KeychainKey.token)
		Constants.removeKeychain(forKey: Constants.KeychainKey.authorization)
		Constants.removeKeychain(forKey: Constants.KeychainKey.email)
	}
}
