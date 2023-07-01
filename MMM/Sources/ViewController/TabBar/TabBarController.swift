//
//  TabBarController.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/04/04.
//

import UIKit
import Combine
import Then
import SnapKit

final class TabBarController: UIViewController {
	private var tabBarVC = UITabBarController()
	
	private lazy var customTabBar = CustomTabBar(tabItems: [.home, .add, .profile])
	private var cancellables = Set<AnyCancellable>()
	private var tabVCs: [UIViewController] = []
	
	private var viewModel = TabBarViewModel()
	private var widgetIndex: Int
	private var preSelected = 0
	
	init(widgetIndex: Int) {
		self.widgetIndex = widgetIndex
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setup()
		
		if widgetIndex == 1 {
			let shouldFrontView = tabVCs[0]
			shouldFrontView.navigationController?.pushViewController(AddViewController(parentVC: shouldFrontView), animated: false)
		}
	}
}
// MARK: - Style & Layout
extension TabBarController {
	private func setup() {
		bind()
		setAttribute()
		setLayout()
	}
	
	private func bind() {
		customTabBar.$selectedIndex
			.receive(on: DispatchQueue.main)
			.sink { [weak self] index in
				guard let self = self else { return }
				self.bindCurrentIndex()
			}.store(in: &cancellables)
	}
	
	private func setAttribute() {
		view.addSubview(customTabBar)
        
        self.view.bringSubviewToFront(self.customTabBar.plusButton)
		customTabBar.tabItems
			.enumerated()
			.forEach { i, item in
				if item == .add {
					
				} else {
					var rootVC = UIViewController()
					
					if item == .home {
						rootVC = HomeViewController(tabBarViewModel: viewModel)
					} else if item == .profile {
						rootVC = ProfileViewController(tabBarViewModel: viewModel)
					}
					var index = i
					if i > 0 { index -= 1 }
					
//                    let vc = NavigationController(rootViewController: rootVC)
					let vc = rootVC
					addChild(vc)
					view.addSubview(vc.view)
					vc.didMove(toParent: self)
					
					vc.view.snp.makeConstraints {
						$0.top.left.right.bottom.equalToSuperview()
					}
					
					tabVCs.append(vc)
				}

			}
		
		guard let shouldFrontView = tabVCs[0].view else { return }
		tabVCs.enumerated().forEach { i, item in
			if i == 0 {
				view.bringSubviewToFront(shouldFrontView)
				view.bringSubviewToFront(customTabBar)
			} else {
				guard let view = item.view else { return }
				view.isHidden = true
			}
		}
//        view.bringSubviewToFront(shouldFrontView)
//        view.bringSubviewToFront(customTabBar)
	}
	
	private func setLayout() {
		customTabBar.snp.makeConstraints {
			$0.leading.bottom.trailing.equalToSuperview()
			$0.top.equalTo(view.snp.bottom).offset(-82)
		}
	}
}

// MARK: - Action
extension TabBarController {
	private func bindCurrentIndex() {
		var index = customTabBar.selectedIndex
		// add 버튼이 눌렸을 경우
		if index == 1 {
			if preSelected == 0 { viewModel.isPlusButtonTappedInHome = true }
			if preSelected == 1 {
				viewModel.isPlusButtonTappedInProfile = true
			}
		} else {
			if customTabBar.selectedIndex > 0 {
				index -= 1
			}
			preSelected = index
			
			if let navigationController = self.navigationController {
				if let rootVC = navigationController.viewControllers.first {
					rootVC.navigationController?.setNavigationBarHidden(index == 0 ? false : index == 1 ? true : false, animated: false)
				}
			}
			
			tabVCs.enumerated().forEach { i, item in
				guard let view = item.view else { return }
				
				if i == index {
					guard let shouldFrontView = tabVCs[index].view else { return }
					view.bringSubviewToFront(shouldFrontView)
					view.isHidden = false
				} else {
					view.isHidden = true
				}
				view.bringSubviewToFront(customTabBar)
			}
		}
	}
}
