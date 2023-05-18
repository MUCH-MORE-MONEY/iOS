//
//  HighlightViewController.swift
//  MMM
//
//  Created by geonhyeong on 2023/05/19.
//

import UIKit
import Combine
import Then
import SnapKit

final class HighlightViewController: UIViewController {
	// MARK: - Properties
	private lazy var cancellable: Set<AnyCancellable> = .init()
	private let viewModel: HomeViewModel

	init(viewModel: HomeViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	// Compile time에 error를 발생시키는 코드
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - UI Components
    override func viewDidLoad() {
        super.viewDidLoad()
		setup()		// 초기 셋업할 코드들
    }
}

//MARK: - Action
private extension HighlightViewController {
}

//MARK: - Style & Layouts
private extension HighlightViewController {
	// 초기 셋업할 코드들
	func setup() {
		bind()
		setAttribute()
		setLayout()
	}
	
	private func bind() {
	}
	
	private func setAttribute() {
	}
	
	private func setLayout() {
	}
}
