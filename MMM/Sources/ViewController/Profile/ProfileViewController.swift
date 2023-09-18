//
//  ViewController.swift
//  MMM
//
//  Created by geonhyeong on 2023/03/28.
//

import UIKit
import Then
import SnapKit
import ReactorKit

// 상속하지 않으려면 final 꼭 붙이기
final class ProfileViewController: BaseViewController, View {
	typealias Reactor = ProfileReactor
	
	// MARK: - Constants
	private enum UI {
		static let titleWidth: CGFloat = 150
		static let titleHeight: CGFloat = 44
		static let headerHeight: CGFloat = 170
		static let dummyCellHeight: CGFloat = 16
		static let cellHeight: CGFloat = 44
	}
	
	// MARK: - Properties
	private var email: String = ""
	private let lableCellList = ["", "계정 관리", "데이터 내보내기", "알림 설정","문의 및 서비스 약관", "앱 버전"]
	
	// MARK: - UI Components
	private lazy var navigationLabel = UILabel()
	private lazy var profileHeaderView = ProfileHeaderView()
	private lazy var profileFooterView = ProfileFooterView()
	private lazy var tableView = UITableView()
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		// Root View인 NavigationView에 item 수정하기
		if let navigationController = self.navigationController {
			if let rootVC = navigationController.viewControllers.first {
				let view = UIView(frame: .init(origin: .zero, size: .init(width: UI.titleWidth, height: UI.titleHeight)))
				view.addSubview(navigationLabel)
				
				rootVC.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: view)
				rootVC.navigationItem.rightBarButtonItem = nil
			}
		}
	}
	
	func bind(reactor: ProfileReactor) {
		bindState(reactor)
		bindAction(reactor)
	}
}
//MARK: - Bind
extension ProfileViewController {
	// MARK: 데이터 변경 요청 및 버튼 클릭시 요청 로직(View -> Reactor)
	private func bindAction(_ reactor: ProfileReactor) {
		// 사용자 Email
		reactor.state
			.compactMap { $0.userEmail } // nil 무시
			.distinctUntilChanged() // 중복값 무시
			.bind(onNext: { email in
				self.email = email
				self.profileHeaderView.setData(email: email)
			})
			.disposed(by: disposeBag)
	}
	
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: ProfileReactor) {
	}
}
//MARK: - Attribute & Hierarchy & Layouts
extension ProfileViewController {
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()
		// [view]
		view.backgroundColor = R.Color.gray100
		
		navigationLabel = navigationLabel.then {
			$0.frame = CGRect(x: 8, y: 0, width: 130, height: 44.0)
			$0.text = "마이페이지"
			$0.font = R.Font.h2
			$0.textColor = R.Color.gray200
			$0.textAlignment = .left
		}
		
		profileHeaderView = profileHeaderView.then {
			$0.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: UI.headerHeight)
		}
		
		tableView = tableView.then {
			$0.delegate = self
			$0.dataSource = self
			$0.showsVerticalScrollIndicator = false
			$0.backgroundColor = R.Color.gray100
			$0.tableHeaderView = profileHeaderView
			$0.tableFooterView = profileFooterView
			$0.bounces = false			// TableView Scroll 방지
			$0.separatorStyle = .none
			$0.register(ProfileTableViewCell.self)
		}
	}
	
	override func setHierarchy() {
		super.setHierarchy()
		
		view.addSubviews(tableView)
	}
	
	override func setLayout() {
		super.setLayout()
		
		tableView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
	}
}
// MARK: - UITableView DataSource
extension ProfileViewController: UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.row == 0 {
			return UI.dummyCellHeight
		}
		return UI.cellHeight
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return lableCellList.count - 1 // 첫번째 Dunmmy Cell 제외
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.className, for: indexPath) as! ProfileTableViewCell
		
		if indexPath.row == 0 { // 첫번째 Dunmmy Cell
			cell.isUserInteractionEnabled = false // click disable
			cell.setData(text: "", last: true)
			cell.isNavigationHidden()
		} else {
			cell.setData(text: lableCellList[indexPath.row], last: indexPath.row == lableCellList.count - 1)
		}
		
		cell.backgroundColor = R.Color.gray100
		
		let backgroundView = UIView()
		backgroundView.backgroundColor = R.Color.gray400.withAlphaComponent(0.3)
		cell.selectedBackgroundView = backgroundView
		
		return cell
	}
}
// MARK: - UITableView Delegate
extension ProfileViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		// 셀 터치시 회색 표시 없애기
		tableView.deselectRow(at: indexPath, animated: true)

		switch indexPath.row {
		case 1:
			let vc = ManagementViewController(email: email)
			vc.reactor = reactor
			vc.hidesBottomBarWhenPushed = true	// TabBar Above
			navigationController?.pushViewController(vc, animated: true)	// 계정관리
		case 2:
			let vc = DataExportViewController()
			vc.hidesBottomBarWhenPushed = true	// TabBar Above
			navigationController?.pushViewController(vc, animated: true)	// 계정관리
		case 3:
			let vc = PushSettingViewController()
			vc.reactor = PushSettingReactor()
			vc.hidesBottomBarWhenPushed = true	// TabBar Above
			navigationController?.pushViewController(vc, animated: true)	// 계정관리
		case 4:
			let vc = ServiceViewController()
			vc.hidesBottomBarWhenPushed = true	// TabBar Above
			navigationController?.pushViewController(vc, animated: true)	// 계정관리
		default:
			break
		}
	}
}
