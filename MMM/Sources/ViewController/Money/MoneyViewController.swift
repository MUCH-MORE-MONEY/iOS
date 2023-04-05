//
//  MoneyViewController.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/04/04.
//

import UIKit
import Then
import SnapKit

final class MoneyViewController: BaseViewController {
    // MARK: - UI Components
    private lazy var imageView = UIImageView().then {
        $0.image = R.Icon.iconMoneyActive
        $0.contentMode = .scaleAspectFit
        $0.layer.masksToBounds = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setNavigationBarHidden(true, animated: animated)	// navigation bar 숨김
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		self.navigationController?.setNavigationBarHidden(false, animated: animated) // navigation bar 노출
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent // status text color 변경
	}
}

// MARK: - Style & Layout
private extension MoneyViewController {
    private func setup() {
        setAttribute()
        setLayout()
    }
    
    private func setAttribute() {
        view.addSubview(imageView)
    }
    
    private func setLayout() {
        imageView.snp.makeConstraints {
			$0.centerY.centerX.equalToSuperview()
        }
    }
}
