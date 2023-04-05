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
	
	private lazy var tableView = UITableView()
	
	override func viewDidLoad() {
        super.viewDidLoad()
		setup()		// 초기 셋업할 코드들
    }
    
	override func viewWillAppear(_ animated: Bool) {
		navigationController?.setNavigationBarHidden(false, animated: animated)	// navigation bar 노출
	}
}

//MARK: - Action
extension ManagementViewController: CustomAlertDelegate {
	@objc func didTapBackButton(_ sender: UITapGestureRecognizer) {
		print()
		navigationController?.popViewController(animated: true)
	}
	
	// 확인 버튼 이벤트 처리
	func didAlertCofirmButton() {
		if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
			sceneDelegate.window?.rootViewController = sceneDelegate.onboarding
		}
	}
	
	// 취소 버튼 이벤트 처리
	func didAlertCacelButton() { }
}

//MARK: - Style & Layouts
extension ManagementViewController {
	
	public func setData(email: String) {
		userEmailLabel.text = email
	}
	
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
		
		tableView = tableView.then {
			$0.delegate = self
			$0.dataSource = self
			$0.showsVerticalScrollIndicator = false
			$0.backgroundColor = R.Color.gray100
			$0.bounces = false			// TableView Scroll 방지
			$0.separatorStyle = .none
			$0.register(ProfileTableViewCell.self)
		}
		
		view.addSubviews(baseView, tableView)
		baseView.addSubviews(userInfoLabel, emailLabel, userEmailLabel, userLoginLabel)
	}
	
	private func setLayout() {
		baseView.snp.makeConstraints {
			$0.top.equalTo(view.safeAreaLayoutGuide).inset(24)
			$0.right.left.equalToSuperview().inset(24)
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
		
		tableView.snp.makeConstraints {
			$0.top.equalTo(userLoginLabel.snp.bottom).offset(16)
			$0.left.right.equalToSuperview()
			$0.height.equalTo(88)
		}
	}
}

// MARK: - UITableView DataSource
extension ManagementViewController: UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 44
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 2
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.className, for: indexPath) as! ProfileTableViewCell
		
		switch indexPath.row {
		case 0:
			cell.setUp(text: "로그아웃")
		default:
			cell.setUp(text: "탈퇴하기")
		}
		
		cell.backgroundColor = R.Color.gray100
		
		return cell
	}
}

// MARK: - UITableView Delegate
extension ManagementViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		// 셀 터치시 회색 표시 없애기
		tableView.deselectRow(at: indexPath, animated: true)
		
		switch indexPath.row {
		case 0:
			showAlert(alertType: .canCancel, titleText: "로그아웃 하시겠어요?", contentText: "로그아웃해도 해당 계정의 데이터는 \n 계속 저장되어 있습니다.", cancelButtonText: "취소하기", confirmButtonText: "로그아웃")
		case 1:
			let vs = WithdrawViewController()
			navigationController?.pushViewController(vs, animated: true)		// 계정관리
		default:
			break
		}
	}
}
