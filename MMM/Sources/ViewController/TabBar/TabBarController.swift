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
        let moneyVC = NavigationController(rootViewController: MoneyViewController())
        let moneyTab = UITabBarItem(title: "소비", image: R.Icon.iconMoneyInActive, tag: 0)
        moneyTab.selectedImage = R.Icon.iconMoneyActive
        moneyVC.tabBarItem = moneyTab
        
        let profileVC = NavigationController(rootViewController: ProfileViewController())
//        let profileTab = UITabBarItem(title: "마이페이지", image: R.Icon.iconMypageInActive, tag: 1)
        
//        profileTab.selectedImage = R.Icon.iconMypageActive
		
//        profileVC.tabBarItem = profileTab
		profileVC.tabBarItem.selectedImage = R.Icon.iconMypageActive
		profileVC.tabBarItem.title = "마이페이지"
        profileVC.tabBarItem.image = R.Icon.iconMoneyInActive
		
		tabBar.isTranslucent = false						// 불투명도
        tabBar.barTintColor = R.Color.orange500
		tabBar.tintColor = R.Color.gray900
        tabBar.unselectedItemTintColor = R.Color.gray900
//		modalPresentationStyle = .fullScreen
//		modalTransitionStyle = .crossDissolve				// 전환 효과
        viewControllers = [moneyVC, profileVC]
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
