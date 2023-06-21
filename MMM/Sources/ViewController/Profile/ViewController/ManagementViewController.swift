//
//  ManagementViewController.swift
//  MMM
//
//  Created by geonhyeong on 2023/03/30.
//

import UIKit
import Then
import SnapKit

final class ManagementViewController: BaseViewController {
	// MARK: - Properties
	private let viewModel: ProfileViewModel
	private lazy var showWithdraw: Bool = false

	// MARK: - UI components
	private lazy var baseView = UIView()
	private lazy var userInfoLabel = UILabel()
	private lazy var emailLabel = UILabel()
	private lazy var userEmailLabel = UILabel()
	private lazy var userLoginLabel = UILabel()
	private lazy var tableView = UITableView()
	
	init(viewModel: ProfileViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	// Compile time에 error를 발생시키는 코드
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		setup()		// 초기 셋업할 코드들
    }
    
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setNavigationBarHidden(false, animated: animated)	// navigation bar 노출
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		if !showWithdraw {
			navigationController?.setNavigationBarHidden(true, animated: animated)	// navigation bar 숨김
		}
	}
}
//MARK: - Action
extension ManagementViewController: CustomAlertDelegate {
	// 외부에서 설정
	public func setData(email: String) {
		userEmailLabel.text = email
	}
	
	// 확인 버튼 이벤트 처리
	func didAlertCofirmButton() {
		if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
			viewModel.logout() // 로그아웃
			sceneDelegate.window?.rootViewController = sceneDelegate.onboarding
		}
	}
	
	// 취소 버튼 이벤트 처리
	func didAlertCacelButton() { }
}
//MARK: - Style & Layouts
private extension ManagementViewController {
	// 초기 셋업할 코드들
	private func setup() {
		setAttribute()
		setLayout()
	}
	
	private func setAttribute() {
		// [view]
		view.backgroundColor = R.Color.gray100
		navigationItem.title = "계정관리"
		
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
	}
	
	private func setLayout() {
		view.addSubviews(baseView, tableView)
		baseView.addSubviews(userInfoLabel, emailLabel, userEmailLabel, userLoginLabel)

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
		case 0: 	cell.setData(text: "로그아웃", last: true)
		default: 	cell.setData(text: "탈퇴하기", last: true)
		}
		
		cell.backgroundColor = R.Color.gray100
		
		let backgroundView = UIView()
		backgroundView.backgroundColor = R.Color.gray400.withAlphaComponent(0.3)
		cell.selectedBackgroundView = backgroundView
		
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
			let vs = WithdrawViewController(viewModel: viewModel)
			showWithdraw = true
			navigationController?.pushViewController(vs, animated: true)		// 계정관리
		default:
			break
		}
	}
}
