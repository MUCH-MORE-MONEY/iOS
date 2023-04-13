//
//  HomeViewController.swift
//  MMM
//
//  Created by geonhyeong on 2023/04/12.
//

import UIKit
import Combine
import Then
import SnapKit

class HomeViewController: UIViewController {
	private lazy var cancellables: Set<AnyCancellable> = .init()
	private let viewModel = HomeViewModel()

	// MARK: - UI Components
	private lazy var imageView = UIImageView()
	private lazy var checkButton = UIButton()

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

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
//		navigationController?.setNavigationBarHidden(true, animated: animated)	// navigation bar 숨김
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.navigationController?.setNavigationBarHidden(false, animated: animated) // navigation bar 노출
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent // status text color 변경
	}
}

//MARK: - Action
extension HomeViewController {	
	func toggleCheckButton(_ isEnabled: Bool) {
		checkButton.setImage(checkButton.isSelected ? R.Icon.checkInActive : R.Icon.checkActive, for: .normal)
		checkButton.backgroundColor = checkButton.isSelected ? R.Color.white : R.Color.gray900
		checkButton.isSelected = !checkButton.isSelected
	}
	
	// 버튼에 대한 Action
	func go() {
		print()
	}
	
	func go2(_ bool: Bool) {
		print()
	}
}

//MARK: - Style & Layouts
extension HomeViewController {
	private func setup() {
		// 초기 셋업할 코드들
		bind()
		setAttribute()
		setLayout()
	}
	
	private func bind() {
		//MARK: input
		checkButton.tapPublisher
			.receive(on: DispatchQueue.main)
			.sinkOnMainThread(receiveValue: go)
			.store(in: &cancellables)
		
		// 예시
		UITextField().textPublisher
			.receive(on: DispatchQueue.main)
			.assign(to: \.passwordInput, on: viewModel)
			.store(in: &cancellables)
		
		//MARK: output
//		viewModel
//			.transform(input: viewModel.input.eraseToAnyPublisher())
//			.sinkOnMainThread(receiveValue: { [weak self] state in
//				switch state {
//				case .errorMessage(_):
//					break
//				case .toggleButton(isEnabled: let isEnabled):
//					self?.toggleCheckButton(isEnabled)
//				}
//			}).store(in: &cancellables)
		viewModel.isMatchPasswordInput
			.receive(on: DispatchQueue.main)
			.sink(receiveValue: go2)
			.store(in: &cancellables)
	}
	
	private func setAttribute() {
		// [view]
		view.backgroundColor = R.Color.gray100
		
		imageView = imageView.then {
			$0.image = R.Icon.iconMoneyActive
			$0.contentMode = .scaleAspectFit
			$0.layer.masksToBounds = true
		}
		
		checkButton = checkButton.then {
			$0.setImage(R.Icon.checkInActive, for: .normal)
			$0.backgroundColor = R.Color.white
			$0.layer.cornerRadius = 4
//			$0.addTarget(self, action: #selector(didTapCheckButton), for: .touchUpInside)
		}
		
		view.addSubview(checkButton)
	}
	
	private func setLayout() {
		checkButton.snp.makeConstraints {
			$0.centerY.centerX.equalToSuperview()
		}
	}
}
