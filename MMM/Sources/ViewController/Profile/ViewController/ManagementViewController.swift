//
//  ManagementViewController.swift
//  MMM
//
//  Created by geonhyeong on 2023/03/30.
//

import UIKit
import Then
import SnapKit

class ManagementViewController: UIViewController {

	private lazy var profileView = ProfileView()
	
	private lazy var backButton = UIBarButtonItem()
	
	override func viewDidLoad() {
        super.viewDidLoad()
		setup()		// 초기 셋업할 코드들
    }
    
	override func viewWillAppear(_ animated: Bool) {
		navigationController?.setNavigationBarHidden(false, animated: animated)	// navigation bar 노출
	}
}

//MARK: - Action
private extension ManagementViewController {
	
	@objc func didTapBackButton(_ sender: UITapGestureRecognizer) {
		print()
		navigationController?.popViewController(animated: true)
	}
}

//MARK: - Style & Layouts
private extension ManagementViewController {
	
	private func setup() {
		// 초기 셋업할 코드들
		setAttribute()
		setLayout()
	}
	
	private func setAttribute() {
		// [view]
		view.backgroundColor = R.Color.gray100
		navigationItem.leftBarButtonItem = backButton
		navigationItem.title = "계정관리"
		
		backButton = backButton.then {
			$0.image = R.Icon.arrowBack24
			$0.style = .plain
			$0.target = self
			$0.action = #selector(didTapBackButton)
		}
		
		view.addSubviews(profileView)
	}
	
	private func setLayout() {
		profileView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
	}
}
