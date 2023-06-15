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
    private var tabVCs: [UINavigationController] = []
    
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
        self.navigationController?.setNavigationBarHidden(true, animated: false)
//        hideKeyboardWhenTappedAround()
        //        setupTabBar()
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
        
        viewModel.$isTabbarHidden
            .receive(on: DispatchQueue.main)
            .sink {
                self.customTabBar.isHidden = $0 ? true : false
            }.store(in: &cancellables)
    }
    
    private func setAttribute() {
        view.addSubview(customTabBar)
        
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
                    
                    let vc = NavigationController(rootViewController: rootVC)
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
        view.bringSubviewToFront(shouldFrontView)
        view.bringSubviewToFront(customTabBar)
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
            if preSelected == 0 { viewModel.plusButtonTappedByHome = true }
            if preSelected == 1 { viewModel.plusButtonTappedByProfile = true }
        } else {
            if customTabBar.selectedIndex > 0 {
                index -= 1
            }
            preSelected = index
            guard let shouldFrontView = tabVCs[index].view else { return }
            view.bringSubviewToFront(shouldFrontView)
            view.bringSubviewToFront(customTabBar)
        }
    }
}
