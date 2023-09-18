//
//  ManagementViewController.swift
//  MMM
//
//  Created by geonhyeong on 2023/03/30.
//

import UIKit
import Then
import SnapKit
import ReactorKit

// 상속하지 않으려면 final 꼭 붙이기
final class ManagementViewController: BaseViewControllerWithNav, View {
	typealias Reactor = ProfileReactor

	// MARK: - Constants
	private enum UI {
		static let baseViewMargin: UIEdgeInsets = .init(top: 24, left: 24, bottom: 0, right: 24)
		static let emailLabelMargin: UIEdgeInsets = .init(top: 16, left: 0, bottom: 0, right: 0)
		static let userEmailLabelMargin: UIEdgeInsets = .init(top: 16, left: 12, bottom: 0, right: 0)
		static let userLoginLabelMargin: UIEdgeInsets = .init(top: 48, left: 0, bottom: 0, right: 0)
		static let tableViewMargin: UIEdgeInsets = .init(top: 16, left: 0, bottom: 0, right: 0)
		static let tableViewHeight: CGFloat = 88
		static let cellHeight: CGFloat = 44
	}
	
	// MARK: - Properties
	private let email: String
	
	// MARK: - UI components
	private lazy var baseView = UIView()
	private lazy var userInfoLabel = UILabel()
	private lazy var emailLabel = UILabel()
	private lazy var userEmailLabel = UILabel()
	private lazy var userLoginLabel = UILabel()
	private lazy var tableView = UITableView()
	
	init(email: String) {
		self.email = email
		super.init(nibName: nil, bundle: nil)
	}

	// Compile time에 error를 발생시키는 코드
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	func bind(reactor: ProfileReactor) {
		bindState(reactor)
		bindAction(reactor)
	}
}
//MARK: - Bind
extension ManagementViewController {
	// MARK: 데이터 변경 요청 및 버튼 클릭시 요청 로직(View -> Reactor)
	private func bindAction(_ reactor: ProfileReactor) {
	}
	
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: ProfileReactor) {
	}
}
//MARK: - Action
extension ManagementViewController: CustomAlertDelegate {
	// 확인 버튼 이벤트 처리
	func didAlertCofirmButton() {
		if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
			reactor?.action.onNext(.logout) // 로그아웃
			sceneDelegate.window?.rootViewController = sceneDelegate.onboarding
		}
	}
	
	// 취소 버튼 이벤트 처리
	func didAlertCacelButton() { }
}
//MARK: - Attribute & Hierarchy & Layouts
extension ManagementViewController {
	// 초기 셋업할 코드들
	override func setAttribute() {
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
			$0.text = email
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
	
	override func setHierarchy() {
		super.setHierarchy()
		
		view.addSubviews(baseView, tableView)
		baseView.addSubviews(userInfoLabel, emailLabel, userEmailLabel, userLoginLabel)
	}
	
	override func setLayout() {
		baseView.snp.makeConstraints {
			$0.top.equalTo(view.safeAreaLayoutGuide).inset(UI.baseViewMargin.top)
			$0.leading.trailing.equalToSuperview().inset(UI.baseViewMargin.left)
		}
		
		userInfoLabel.snp.makeConstraints {
			$0.leading.top.equalToSuperview()
		}
		
		emailLabel.snp.makeConstraints {
			$0.top.equalTo(userInfoLabel.snp.bottom).offset(UI.emailLabelMargin.top)
			$0.leading.equalToSuperview()
		}
		
		userEmailLabel.snp.makeConstraints {
			$0.top.equalTo(userInfoLabel.snp.bottom).offset(UI.userEmailLabelMargin.top)
			$0.leading.equalTo(emailLabel.snp.trailing).offset(UI.userEmailLabelMargin.left)
		}
		
		userLoginLabel.snp.makeConstraints {
			$0.left.equalToSuperview()
			$0.top.equalTo(emailLabel.snp.bottom).offset(UI.userLoginLabelMargin.top)
		}
		
		tableView.snp.makeConstraints {
			$0.top.equalTo(userLoginLabel.snp.bottom).offset(UI.tableViewMargin.top)
			$0.leading.trailing.equalToSuperview()
			$0.height.equalTo(UI.tableViewHeight)
		}
	}
}
// MARK: - UITableView DataSource
extension ManagementViewController: UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UI.cellHeight
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
			let vc = WithdrawViewController()
			vc.reactor = WithdrawReactor()
			navigationController?.pushViewController(vc, animated: true)		// 계정관리
			break
		default:
			break
		}
	}
}
