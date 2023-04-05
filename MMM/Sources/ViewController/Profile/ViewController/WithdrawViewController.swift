//
//  WithdrawViewController.swift
//  MMM
//
//  Created by geonhyeong on 2023/04/04.
//

import UIKit

class WithdrawViewController: UIViewController {

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
extension WithdrawViewController: CustomAlertDelegate {
	@objc func didTapBackButton(_ sender: UITapGestureRecognizer) {
		print()
		navigationController?.popViewController(animated: true)
	}
	
	// 확인 버튼 이벤트 처리
	func didAlertCofirmButton() { }
	
	// 취소 버튼 이벤트 처리
	func didAlertCacelButton() { }
}

//MARK: - Style & Layouts
extension WithdrawViewController {
	
	private func setup() {
		// 초기 셋업할 코드들
		setAttribute()
		setLayout()
	}
	
	private func setAttribute() {
		// [view]
		view.backgroundColor = R.Color.gray100
		navigationItem.leftBarButtonItem = backButton
		navigationItem.title = "회원탈퇴"
		
		backButton = backButton.then {
			$0.image = R.Icon.arrowBack24
			$0.style = .plain
			$0.target = self
			$0.action = #selector(didTapBackButton)
		}
	}
	
	private func setLayout() {
	}
}
