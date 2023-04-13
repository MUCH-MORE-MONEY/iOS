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
	private lazy var checkButton = UIButton()
	private lazy var monthButton = UIBarButtonItem()
	private lazy var todayButton = UIBarButtonItem()
	private lazy var settingButton = UIBarButtonItem()

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
		navigationItem.leftBarButtonItem = monthButton
		navigationItem.rightBarButtonItems = [settingButton, todayButton]
		
		monthButton = monthButton.then {
			let button = UIButton()
			button.frame = .init(origin: .zero, size: .init(width: 49, height: 24))
			button.setTitle("3월", for: .normal)
			button.setImage(R.Icon.arrowExpandMore16, for: .normal)
			button.setTitleColor(R.Color.white, for: .normal)
			button.setTitleColor(R.Color.white.withAlphaComponent(0.7), for: .highlighted)
			button.imageView?.contentMode = .scaleAspectFit
			button.titleLabel?.font = R.Font.h5
			button.contentHorizontalAlignment = .center
			button.semanticContentAttribute = .forceRightToLeft //<- 중요
			button.imageEdgeInsets = .init(top: 0, left: 11, bottom: 0, right: 0) // 이미지 여백
			$0.customView = button
		}
		
		todayButton = todayButton.then {
			let button = UIButton()
			button.frame = .init(origin: .zero, size: .init(width: 49, height: 24))
			button.setTitle("오늘", for: .normal)
			button.setTitleColor(R.Color.gray300, for: .normal)
			button.setBackgroundColor(R.Color.gray800, for: .highlighted)
			button.titleLabel?.font = R.Font.body3
			button.layer.cornerRadius = 12
			button.layer.borderWidth = 2
			button.layer.borderColor = R.Color.gray800.cgColor
			$0.customView = button
		}
		
		settingButton = settingButton.then {
			$0.image = R.Icon.setting
			$0.style = .plain
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
