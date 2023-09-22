//
//  ChallengeViewController.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/09/07.
//

import UIKit

final class ChallengeViewController: BaseViewControllerWithNav {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navigationController = self.navigationController {
            if let rootVC = navigationController.viewControllers.first {
                let view = UIView(frame: .init(origin: .zero, size: .init(width: 150, height: 44)))
                
                rootVC.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: view)
                rootVC.navigationItem.rightBarButtonItem = nil
            }
        }
    }
}
