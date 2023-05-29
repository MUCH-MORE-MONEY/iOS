//
//  AddViewController.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/04/14.
//

import UIKit
import Combine
import Then
import SnapKit

final class AddViewController: BaseViewController {
	// MARK: - Properties
	private lazy var cancellable: Set<AnyCancellable> = .init()

	// MARK: - UI Components
	
	public init() {
		super.init(nibName: nil, bundle: nil)
	}
	
	// Compile time에 error를 발생시키는 코드
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setup()		// 초기 셋업할 코드들
	}
}
//MARK: - Action
extension AddViewController {
	
}
//MARK: - Style & Layouts
private extension AddViewController {
	// 초기 셋업할 코드들
	private func setup() {
		bind()
		setAttribute()
		setLayout()
	}
	
	private func bind() {
		//MARK: input
		//MARK: output
	}
	
	private func setAttribute() {
		// [view]
		view.backgroundColor = R.Color.gray900
		title = "경제활동 추가"

	}
	
	private func setLayout() {
	}
}
