//
//  BaseViewController.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/04/04.
//

import UIKit
import Then
import Combine

class BaseViewController: UIViewController {
    // MARK: - UI Components
    private lazy var backButtonItem = UIBarButtonItem()
    lazy var backButton = UIButton()
    
    // MARK: - Properties
    private var cancellable = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
        // 수평적확장을 해야하기 때문에 extension에서 사용불가
        backButton.tapPublisher
            .sinkOnMainThread(receiveValue: didTapBackButton)
            .store(in: &cancellable)
    }
    
    /// BaseViewController를 상속받은 객체는 항상 이 메서드를 구현해야합니다
    /// 뒤로가기에 대한 navigation pop 함수입니다.
    func didTapBackButton() {
        if navigationController?.viewControllers.count == 1 {
            tabBarController?.selectedIndex = 0
        } else {
            navigationController?.popViewController(animated: true)
        }

    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // status text color 변경
    }
}
//MARK: - Attribute & Hierarchy & Layouts
extension BaseViewController {
    private func setup() {
        setAttribute()
        setLayout()
    }
    
    private func setAttribute() {
        backButtonItem = backButtonItem.then {
            $0.customView = backButton
        }
        navigationItem.leftBarButtonItem = backButtonItem
        view.backgroundColor = R.Color.gray100
        backButton = backButton.then {
            $0.setImage(R.Icon.arrowBack24, for: .normal)
        }
    }
    
    private func setLayout() {}
}
