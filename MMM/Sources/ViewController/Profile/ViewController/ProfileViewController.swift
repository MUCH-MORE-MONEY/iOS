//
//  ViewController.swift
//  MMM
//
//  Created by geonhyeong on 2023/03/28.
//

import UIKit
import Then
import SnapKit
import Combine

// 상속하지 않으려면 final 꼭 붙이기
final class ProfileViewController: UIViewController {
	// MARK: - Properties
	private var viewModel: ProfileViewModel = ProfileViewModel()
	private var userEmail: String = ""
	private let lableCellList = ["", "계정 관리", "데이터 내보내기", "알림 설정","문의 및 서비스 약관", "앱 버전"]
    private var tabBarViewModel: TabBarViewModel
    private var cancellable = Set<AnyCancellable>()
    
	// MARK: - UI Components
	private lazy var navigationLabel = UILabel()
	private lazy var monthButton = UIButton()

	private lazy var profileHeaderView = ProfileHeaderView()
	private lazy var profileFooterView = ProfileFooterView()
	private lazy var tableView = UITableView()
    
	override func viewDidLoad() {
		super.viewDidLoad()
		setup()		// 초기 셋업할 코드들
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		// Root View인 NavigationView에 item 수정하기
		if let navigationController = self.navigationController {
			if let rootVC = navigationController.viewControllers.first {
				let view = UIView(frame: .init(origin: .zero, size: .init(width: 150, height: 44)))
				view.addSubview(navigationLabel)
				
				rootVC.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: view)
				rootVC.navigationItem.rightBarButtonItem = nil
			}
		}
	}
}
//MARK: - Style & Layouts
private extension ProfileViewController {
	// 초기 셋업할 코드들
	private func setup() {
        bind()
		setAttribute()
		setLayout()
	}
	
    private func bind() {
        guard let email = Constants.getKeychainValue(forKey: Constants.KeychainKey.email) else { return }
        userEmail = email
    }
    
	private func setAttribute() {
		// [view]
		view.backgroundColor = R.Color.gray100
		
		navigationLabel = navigationLabel.then {
			$0.frame = CGRect(x: 8, y: 0, width: 130, height: 44.0)
			$0.text = "마이페이지"
			$0.font = R.Font.h2
			$0.textColor = R.Color.gray200
			$0.textAlignment = .left
		}
		
		monthButton = monthButton.then {
			$0.frame = .init(origin: .init(x: 8, y: 0), size: .init(width: 80, height: 30))
			$0.setTitle(Date().getFormattedDate(format: "M월"), for: .normal)
			$0.setImage(R.Icon.arrowExpandMore16, for: .normal)
			$0.setTitleColor(R.Color.white, for: .normal)
			$0.setTitleColor(R.Color.white.withAlphaComponent(0.7), for: .highlighted)
			$0.imageView?.contentMode = .scaleAspectFit
			$0.titleLabel?.font = R.Font.h5
			$0.contentHorizontalAlignment = .left
			$0.imageEdgeInsets = .init(top: 0, left: 8, bottom: 0, right: 0) // 이미지 여백
		}


		profileHeaderView = profileHeaderView.then {
			$0.setData(email: userEmail)
			$0.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 170)
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
	
	private func setLayout() {
		view.addSubviews(tableView)
		
		tableView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
	}
}
// MARK: - UITableView DataSource
extension ProfileViewController: UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.row == 0 {
			return 16
		}
		return 44
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 5
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.className, for: indexPath) as! ProfileTableViewCell

		if indexPath.row == 0 {
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
			let vc = ManagementViewController(viewModel: viewModel)
			vc.setData(email: userEmail)
			vc.hidesBottomBarWhenPushed = true	// TabBar Above
			navigationController?.pushViewController(vc, animated: true)	// 계정관리
        case 2:
			let vc = DataExportViewController()
			vc.hidesBottomBarWhenPushed = true	// TabBar Above
            navigationController?.pushViewController(vc, animated: true)
        case 3:
            let vc = PushSettingViewController()
            vc.reactor = PushSettingReactor()
            vc.hidesBottomBarWhenPushed = true    // TabBar Above
            navigationController?.pushViewController(vc, animated: true)
        case 4:
            let vc = ServiceViewController()
			vc.hidesBottomBarWhenPushed = true	// TabBar Above
            navigationController?.pushViewController(vc, animated: true)
		default:
			break
		}
	}
}
