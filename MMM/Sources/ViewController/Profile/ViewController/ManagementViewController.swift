//
//  ManagementViewController.swift
//  MMM
//
//  Created by geonhyeong on 2023/03/30.
//

import UIKit
import Then
import SnapKit

final class ManagementViewController: UIViewController {

	private lazy var backButton = UIBarButtonItem()

	private lazy var baseView = UIView()
	
	private lazy var userInfoLabel = UILabel()
	
	private lazy var emailLabel = UILabel()

	private lazy var userEmailLabel = UILabel()
	
	private lazy var userLoginLabel = UILabel()
	
	private lazy var logoutButton = UIButton()
	
	private lazy var withdrawalButton = UIButton()

	override func viewDidLoad() {
        super.viewDidLoad()
		setup()		// 초기 셋업할 코드들
    }
    
	override func viewWillAppear(_ animated: Bool) {
		navigationController?.setNavigationBarHidden(false, animated: animated)	// navigation bar 노출
	}
	
	public func setData(email: String) {
		userEmailLabel.text = email
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
		
		userInfoLabel = userInfoLabel.then {
			$0.text = "회원정보"
			$0.font = R.Font.title1
			$0.textColor = R.Color.gray800
		}
		
		emailLabel = emailLabel.then {
			$0.text = "이메일"
			$0.font = R.Font.title3
			$0.textColor = R.Color.gray500
		}
		
		userEmailLabel = userEmailLabel.then {
			$0.font = R.Font.body1
			$0.textColor = R.Color.gray900
		}
		
		userLoginLabel = userLoginLabel.then {
			$0.text = "로그인 관리"
			$0.font = R.Font.title1
			$0.textColor = R.Color.gray800
		}
		
		logoutButton = logoutButton.then {
			$0.setTitle("로그아웃", for: .normal)
			$0.titleLabel?.font = R.Font.body2
			$0.setTitleColor(R.Color.gray900, for: .normal)
			$0.setImage(R.Icon.arrowNext16, for: .normal)
			$0.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
		}
		
		withdrawalButton = withdrawalButton.then {
			$0.setTitle("탈퇴하기", for: .normal)
			$0.titleLabel?.font = R.Font.body2
			$0.setTitleColor(R.Color.gray900, for: .normal)
			$0.setImage(R.Icon.arrowNext16, for: .normal)
			$0.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
		}
		
		view.addSubviews(baseView)
		baseView.addSubviews(userInfoLabel, emailLabel, userEmailLabel, userLoginLabel, logoutButton, withdrawalButton)
	}
	
	private func setLayout() {
		baseView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(24)
			$0.left.equalToSuperview().inset(24)
			$0.right.equalToSuperview().inset(29)
			$0.centerX.equalToSuperview()
			$0.height.equalTo(200)
		}
		
		userInfoLabel.snp.makeConstraints {
			$0.left.top.equalToSuperview()
		}
		
		emailLabel.snp.makeConstraints {
			$0.left.equalToSuperview()
			$0.top.equalTo(userInfoLabel.snp.bottom).offset(16)
		}
		
		userEmailLabel.snp.makeConstraints {
			$0.top.equalTo(userInfoLabel.snp.bottom).offset(16)
			$0.left.equalTo(emailLabel.snp.right).offset(12)
		}
		
		userLoginLabel.snp.makeConstraints {
			$0.left.equalToSuperview()
			$0.top.equalTo(emailLabel.snp.bottom).offset(48)
		}

		logoutButton.snp.makeConstraints {
			$0.left.right.equalToSuperview()
			$0.top.equalTo(userLoginLabel.snp.bottom).offset(16)
			$0.height.equalTo(44)
		}
		
		withdrawalButton.snp.makeConstraints {
			$0.left.right.equalToSuperview()
			$0.top.equalTo(logoutButton.snp.bottom)
			$0.height.equalTo(44)
		}
	}
}
