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
import RxSwift
import RxCocoa

final class TabBarController: UITabBarController {
	private var tabBarVC = UITabBarController()
    private lazy var middleButton = UIButton(type: .custom)
    
    private let disposeBag = DisposeBag()
    
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
//		setup()
		setTabBar()
		if widgetIndex == 1 {
//			let shouldFrontView = tabVCs[0]
//			shouldFrontView.navigationController?.pushViewController(AddViewController(parentVC: shouldFrontView), animated: false)
            // FIXME: - 딥링크 오류 해결
            let vc = AddViewController(parentVC: UIViewController())
            navigationController?.pushViewController(vc, animated: true)
		}
	}
	
	// Profile View에 dark Content로 나타나는 문제 해결
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent // status text color 변경
	}
    
    // UIResponder의 hitTest(_:with:) 메서드 재정의
    
    
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
						let vc = StatisticsViewController(tabBarViewModel: viewModel)
						vc.reactor = StatisticsReactor()
						rootVC = vc
						
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
            $0.top.equalTo(view.snp.bottom).offset(UIDevice.hasNotch ? -82 : -62)
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
            
            Tracking.FinActAddPage.startLogEvent()
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

extension TabBarController {
    
    func setTabBar() {
        
        // 기존 탭 바 아이템을 숨김 처리
        for item in self.tabBar.items ?? [] {
            item.isEnabled = false
            item.title = ""
            item.image = nil
            item.selectedImage = nil
        }
        

        // 탭 바에 커스텀 아이템 추가
        self.tabBar.addSubviews(middleButton)
        
        // 가운데 원형 디자인을 갖는 커스텀 탭 바 아이템 생성
        middleButton = middleButton.then {
            $0.frame = CGRect(x: 0, y: 0, width: 64, height: 64)
            $0.center = CGPoint(x: tabBar.center.x, y: tabBar.bounds.height - 32)
            $0.setImage(R.Icon.iconPlus, for: .normal) // 아이콘 이미지
        }
        

        self.tabBar.tintColor = R.Color.gray900
		self.tabBar.barTintColor = R.Color.gray100
		self.tabBar.isTranslucent = false
        self.tabBar.setTabShadow()
        self.delegate = self
        
        let homeVC = HomeViewController(tabBarViewModel: viewModel)
        homeVC.tabBarItem = UITabBarItem(title: "소비", image: R.Icon.iconMoneyInActive, selectedImage: R.Icon.iconMoneyActive)
        
        let budgetVC = StatisticsViewController(tabBarViewModel: viewModel)
        budgetVC.reactor = StatisticsReactor()
        budgetVC.tabBarItem = UITabBarItem(title: "예산", image: R.Icon.iconMoneyInActive, selectedImage: R.Icon.iconMoneyActive)

        let plusVC = UIViewController()
        plusVC.tabBarItem = UITabBarItem()
        
        let challengeVC = UIViewController()
        challengeVC.tabBarItem = UITabBarItem(title: "챌린지", image: R.Icon.iconMoneyInActive, selectedImage: R.Icon.iconMoneyActive)

        let profileVC = ProfileViewController(tabBarViewModel: viewModel)
        profileVC.tabBarItem = UITabBarItem(title: "마이페이지", image: R.Icon.iconMypageInActive, selectedImage: R.Icon.iconMypageActive)
        
        setViewControllers([homeVC, budgetVC, plusVC, challengeVC, profileVC], animated: false)
    }
}

extension TabBarController: UITabBarControllerDelegate {
    // UITabBarControllerDelegate 메서드 구현
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let index = tabBarController.viewControllers?.firstIndex(of: viewController), index == (tabBarController.viewControllers?.count ?? 0) / 2 {
            // 가운데 탭을 선택하려면 커스텀 아이템을 터치한 것으로 처리
            print("가운데 버튼 tapped")
            
            let vc = AddViewController(parentVC: UIViewController())
            
            navigationController?.pushViewController(vc, animated: true)
            
            return false
        }
        return true
    }
}
