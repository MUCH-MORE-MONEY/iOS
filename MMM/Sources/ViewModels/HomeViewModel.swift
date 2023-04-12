//
//  HomeViewModel.swift
//  MMM
//
//  Created by geonhyeong on 2023/04/12.
//

import Foundation
import Combine

protocol HomeViewModelInput {
	func didTapConfirmButton()
}

final class HomeViewModel: HomeViewModelInput {
	// MARK: - Private properties
	private var currentState: CurrentValueSubject<ViewModelState?, Never> = .init(nil)
	private let cancellables: Set<AnyCancellable> = .init()
	
	var input: HomeViewModelInput { self }
	
	func didTapConfirmButton() {
		print("눌림")
	}
}

//MARK: State
extension HomeViewModel {
	public enum ViewModelState {
		case errorMessage(String)
	}
	
	public var state: AnyPublisher<ViewModelState, Never> { currentState.compactMap { $0 }.eraseToAnyPublisher() }
}
