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

    private lazy var customTabBar = CustomTabBar(tabItems: [.home, .add, .profile])
    private var cancellables = Set<AnyCancellable>()
    private var childVCs = [HomeViewController(), AddViewController(), ProfileViewController()]
    
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
        hideKeyboardWhenTappedAround()
//        setupTabBar()
    }
}

//extension TabBarController: UITabBarControllerDelegate {
//	func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//		//Tab tapped
//		guard let viewControllers = tabBarController.viewControllers else { return }
//		let tappedIndex = viewControllers.firstIndex(of: viewController)!
//
//		if tappedIndex == 1 {
//			selectedIndex = preSelect
//			if let vc = self.viewControllers?[preSelect] as? NavigationController {
//
//				vc.hidesBottomBarWhenPushed = true	// TabBar Above
//
//				vc.viewControllers.first!.navigationController?.pushViewController(AddViewController(), animated: true)
//			}
//		} else {
//			preSelect = selectedIndex
//		}
//	}
//}

// MARK: - Style & Layout
extension TabBarController {

//	private func setupTabBar() {
//		delegate = self
//        tabBar.backgroundColor = R.Color.gray100
//		tabBar.tintColor = R.Color.gray900
//		tabBar.isTranslucent = false						// 불투명도
//
//		let homeVC = NavigationController(rootViewController: HomeViewController())
//		let homeTabItem = UITabBarItem(title: "소비", image: R.Icon.iconMoneyInActive, selectedImage: R.Icon.iconMoneyActive)
//		homeVC.tabBarItem = homeTabItem
//
//        let addVC = NavigationController(rootViewController: AddViewController())
//        addVC.tabBarItem.image = R.Icon.iconPlus
//
//
//
//		let profileVC = NavigationController(rootViewController: ProfileViewController())
//		let profileTabItem = UITabBarItem(title: "마이페이지", image: R.Icon.iconMypageInActive, selectedImage: R.Icon.iconMypageActive)
//		profileVC.tabBarItem = profileTabItem
//
//
//
//        UITabBar.clearShadow()
//        tabBar.layer.applyShadow(color: .gray, alpha: 0.3, x: 0, y: 0, blur: 12)
//
//		viewControllers = [homeVC, addVC, profileVC]
//        self.selectedIndex = widgetIndex
//	}

    private func setup() {
        setAttribute()
        setLayout()
        bind()
    }

    private func setAttribute() {
        view.addSubview(customTabBar)
        
        customTabBar = customTabBar.then {
            $0.layer.borderWidth = 1.0
            $0.layer.borderColor = R.Color.black.cgColor
            $0.layer.masksToBounds = false
        }
        
        customTabBar.tabItems
            .enumerated()
             .forEach { i, item in
                 let vc = NavigationController(rootViewController: childVCs[i])
                 addChild(vc)
                 view.addSubview(vc.view)
                 vc.didMove(toParent: self)

                 vc.view.snp.makeConstraints {
                     $0.top.leading.trailing.equalToSuperview()
                     $0.bottom.equalTo(customTabBar.snp.top)
                 }

                 childVCs.append(vc)
             }
        
        childVCs = childVCs.filter{ $0 is UINavigationController }
        
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
        customTabBar.$selectedIndex
            .receive(on: DispatchQueue.main)
            .sink { [weak self] index in
                guard let self = self else { return }
                self.bindCurrentIndex()
            }.store(in: &cancellables)
    }


    private func bindCurrentIndex() {
//        customTabBar.isHidden = customTabBar.selectedIndex == 1 ? true : false
 
//        if customTabBar.selectedIndex == 1 {
//            customTabBar.snp.remakeConstraints {
//                $0.top.leading.trailing.equalToSuperview()
//                $0.bottom.equalToSuperview()
//            }
//            customTabBar.isHidden = true
//        } else {
//            customTabBar.snp.remakeConstraints {
//                $0.top.leading.trailing.equalToSuperview()
//                $0.bottom.equalTo(customTabBar.snp.top)
//            }
//            preSelected = customTabBar.selectedIndex
//            customTabBar.isHidden = false
//        }
        guard let shouldFrontView = childVCs[customTabBar.selectedIndex].view else { return }
        view.bringSubviewToFront(shouldFrontView)
    }
}
