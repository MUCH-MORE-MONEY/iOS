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
	private var viewModel: HomeViewModel
	
	// MARK: - UI Components
	private lazy var imageView = UIImageView()
	
	public init() {
		self.viewModel = HomeViewModel()
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
		viewModel.state.compactMap { $0 }
			.sinkOnMainThread(receiveValue: { [weak self] state in
				switch state {
				case .errorMessage(let message): break
				}
			}).store(in: &cancellables)
	}
	
	private func setAttribute() {
		// [view]
		view.backgroundColor = R.Color.gray100
		
		imageView = imageView.then {
			$0.image = R.Icon.iconMoneyActive
			$0.contentMode = .scaleAspectFit
			$0.layer.masksToBounds = true
		}
		
		view.addSubview(imageView)
	}
	
	private func setLayout() {
		imageView.snp.makeConstraints {
			$0.centerY.centerX.equalToSuperview()
		}
	}
}
