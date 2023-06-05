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

final class TabBarController: UITabBarController {

    private let customTabBar = CustomTabBar(tabItems: [.home, .add, .profile])
    private lazy var cancellables = Set<AnyCancellable>()
    private lazy var childVCs = [HomeViewController(), AddViewController(), ProfileViewController()]
    
    init() {
        super.init(nibName: nil, bundle: nil)
//        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        setup()
        
        setupTabBar()
//        view.addSubview(customTabBar)
//        customTabBar.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//            customTabBar.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
//            customTabBar.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
//            customTabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
//            customTabBar.heightAnchor.constraint(equalToConstant: 56),
//            customTabBar.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
//        ])
    }
	private lazy var preSelect: Int = 0
}

extension TabBarController: UITabBarControllerDelegate {
	func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
		//Tab tapped
		guard let viewControllers = tabBarController.viewControllers else { return }
		let tappedIndex = viewControllers.firstIndex(of: viewController)!

		if tappedIndex == 1 {
			selectedIndex = preSelect
			if let vc = self.viewControllers?[preSelect] as? NavigationController {

				vc.hidesBottomBarWhenPushed = true	// TabBar Above

				vc.viewControllers.first!.navigationController?.pushViewController(AddViewController(), animated: true)
			}
		} else {
			preSelect = selectedIndex
		}
	}
}

// MARK: - Style & Layout
extension TabBarController {

	private func setupTabBar() {
		delegate = self
        tabBar.backgroundColor = R.Color.gray100
		tabBar.tintColor = R.Color.gray900
		tabBar.isTranslucent = false						// 불투명도

		let homeVC = NavigationController(rootViewController: HomeViewController())
		let homeTabItem = UITabBarItem(title: "소비", image: R.Icon.iconMoneyInActive, selectedImage: R.Icon.iconMoneyActive)
		homeVC.tabBarItem = homeTabItem

        let addVC = NavigationController(rootViewController: AddViewController())
        addVC.tabBarItem.image = R.Icon.iconPlus



		let profileVC = NavigationController(rootViewController: ProfileViewController())
		let profileTabItem = UITabBarItem(title: "마이페이지", image: R.Icon.iconMypageInActive, selectedImage: R.Icon.iconMypageActive)
		profileVC.tabBarItem = profileTabItem



        UITabBar.clearShadow()
        tabBar.layer.applyShadow(color: .gray, alpha: 0.3, x: 0, y: 0, blur: 12)

		viewControllers = [homeVC, addVC, profileVC]
	}

    private func setup() {
        setAttribute()
        setLayout()
        bind()
    }

    private func setAttribute() {
        view.addSubview(customTabBar)

        customTabBar.tabItems
            .enumerated()
             .forEach { i, item in
                 let vc = NavigationController(rootViewController: childVCs[i])
                 addChild(vc)
                 view.addSubview(vc.view)
                 vc.didMove(toParent: self)

                 vc.view.snp.makeConstraints {
                     $0.top.leading.trailing.equalToSuperview()
                     $0.bottom.equalTo(tabBar.snp.top)
                 }

                 childVCs.append(vc)
             }

         guard let shouldFrontView = childVCs[0].view else { return }
         view.bringSubviewToFront(shouldFrontView)
    }

    private func setLayout() {
        customTabBar.snp.makeConstraints {
            $0.leading.bottom.trailing.equalToSuperview()
            $0.top.equalTo(view.snp.bottom).offset(-82)
        }
    }

    private func bind() {
        customTabBar.tabButtons.forEach {
            $0.tapPublisher
                .sinkOnMainThread(receiveValue: bindCurrentIndex)
                .store(in: &cancellables)
        }

    }


    private func bindCurrentIndex() {
        selectedIndex = customTabBar.currentIndex
        guard let shouldFrontView = childVCs[selectedIndex].view else { return }
        view.bringSubviewToFront(shouldFrontView)
    }
}
