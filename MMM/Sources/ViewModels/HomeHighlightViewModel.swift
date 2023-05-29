//
//  HomeHighlightViewModel.swift
//  MMM
//
//  Created by geonhyeong on 2023/05/23.
//

import UIKit
import Combine

final class HomeHighlightViewModel {
	// MARK: - Property Warraper
	@Published var priceInput: String = ""

	// MARK: - Private properties
	private var cancellable: Set<AnyCancellable> = .init()

	// MARK: - Public properties
	// 들어온 퍼블리셔의 값 일치 여부를 반환하는 퍼블리셔
	lazy var isVaild: AnyPublisher<Bool, Never> = $priceInput
		.map { 0 <= Int($0) ?? -1 && Int($0) ?? -1 <= 10_000 } // 1억(1,000만원)보다 작을 경우
		.eraseToAnyPublisher()
	
	// MARK: - Public properties
	// 들어온 퍼블리셔의 값 일치 여부를 반환하는 퍼블리셔
	lazy var isVaildByWon: AnyPublisher<Bool, Never> = $priceInput
		.map { 0 <= Int($0) ?? -1 && Int($0) ?? -1 <= 100_000_000 } // 1억(1,000만원)보다 작을 경우
		.eraseToAnyPublisher()
}
