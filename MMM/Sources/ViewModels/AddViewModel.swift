//
//  AddViewModel.swift
//  MMM
//
//  Created by geonhyeong on 2023/05/29.
//

import UIKit
import Combine

final class AddViewModel {
	// MARK: - Property Warraper
	@Published var date: Date?

	// MARK: - Private properties
	private var cancellable: Set<AnyCancellable> = .init()
}
