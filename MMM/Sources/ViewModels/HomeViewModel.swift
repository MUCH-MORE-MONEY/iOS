//
//  HomeViewModel.swift
//  MMM
//
//  Created by geonhyeong on 2023/04/12.
//

import Foundation
import Combine

final class HomeViewModel {
	// MARK: - Property Warraper
	@Published var passwordInput: String = ""
	@Published var passwordConfirmInput: String = ""

	// MARK: - Private properties
	private var cancellables: Set<AnyCancellable> = .init()
	
	// MARK: - Public properties
	// 들어온 퍼블리셔들의 값 일치 여부를 반환하는 퍼블리셔
	lazy var isMatchPasswordInput: AnyPublisher<Bool, Never> = Publishers
		.CombineLatest($passwordInput, $passwordConfirmInput)
		.map( { (password: String, passwordConfirm: String) in
			if password == "" || passwordConfirm == "" {
				return false
			}
			if password == passwordConfirm {
				return true
			} else {
				return false
			}
		})
		.eraseToAnyPublisher()
}

//MARK: Action
extension HomeViewModel {
	
}

//MARK: State
extension HomeViewModel {
	
}
