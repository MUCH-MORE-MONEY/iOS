//
//  BaseViewController.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/04/04.
//

import UIKit
import Then

class BaseViewController: UIViewController {
    // MARK: - UI Components
    private lazy var backButton = UIBarButtonItem()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

//MARK: - Action
private extension BaseViewController {
    
    @objc func didTapBackButton(_ sender: UITapGestureRecognizer) {
        print()
        navigationController?.popViewController(animated: true)
    }
}


//MARK: - Style & Layouts
extension BaseViewController {
    private func setup() {
        setAttribute()
        setLayout()
    }
    
    private func setAttribute() {
        navigationItem.leftBarButtonItem = backButton
        view.backgroundColor = R.Color.gray100
        backButton = backButton.then {
            $0.image = R.Icon.arrowBack24
            $0.style = .plain
            $0.target = self
            $0.action = #selector(didTapBackButton)
        }
    }
    
    private func setLayout() {}
}
