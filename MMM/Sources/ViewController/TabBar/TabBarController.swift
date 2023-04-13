//
//  TabBarController.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/04/04.
//

import UIKit

final class TabBarController: UITabBarController {
    // MARK: - UI Components
//    private lazy var moneyVC = UIViewController().then {
//        $0.tabBarItem = UITabBarItem(title: "소비", image: R.Icon.iconMoneyActive, tag: 0)
//    }
//
//    private lazy var profileVC = UIViewController().then {
//        $0.tabBarItem = UITabBarItem(title: "마이페이지", image: R.Icon.iconMypageActive, tag: 1)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTabBar()
    }
}

// MARK: - Style & Layout
extension TabBarController {
    
	private func setupTabBar() {
		tabBar.tintColor = R.Color.gray900
		tabBar.isTranslucent = false						// 불투명도
		
		let homeVC = NavigationController(rootViewController: HomeViewController())
		let homeTabItem = UITabBarItem(title: "소비", image: R.Icon.iconMoneyInActive, selectedImage: R.Icon.iconMoneyActive)
		homeVC.tabBarItem = homeTabItem
		
		let profileVC = NavigationController(rootViewController: ProfileViewController())
		let profileTabItem = UITabBarItem(title: "마이페이지", image: R.Icon.iconMypageInActive, selectedImage: R.Icon.iconMypageActive)
		profileVC.tabBarItem = profileTabItem
		
		viewControllers = [homeVC, profileVC]
	}
    
    private func setup() {
        setAttribute()
        setLayout()
    }
    
    private func setAttribute() {
        // tabbar delegate
        self.delegate = self
    }
    
    private func setLayout() {
        
    }
}

// MARK: - TabBarControllerDelegate
extension TabBarController: UITabBarControllerDelegate{
    
}
