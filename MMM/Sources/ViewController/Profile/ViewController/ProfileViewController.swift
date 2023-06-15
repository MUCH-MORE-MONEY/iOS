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
	private let lableCellList = ["", "계정 관리", "데이터 내보내기", "문의 및 서비스 약관", "앱 버전"]
	private let topSafeAreaInsets: CGFloat = {
		let scenes = UIApplication.shared.connectedScenes
		let windowScene = scenes.first as? UIWindowScene
		if let hasWindowScene = windowScene {
			return hasWindowScene.windows.first?.safeAreaInsets.top ?? 0
		} else {
			return 0.0
		}
	}()
    private var tabBarViewModel: TabBarViewModel
    private var cancellable = Set<AnyCancellable>()
    
	// MARK: - UI Components
	private lazy var topArea = UIView()
	private lazy var profileHeaderView = ProfileHeaderView()
	private lazy var profileFooterView = ProfileFooterView()
	private lazy var tableView = UITableView()
	
    init(tabBarViewModel: TabBarViewModel) {
        self.tabBarViewModel = tabBarViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
	override func viewDidLoad() {
		super.viewDidLoad()
		setup()		// 초기 셋업할 코드들
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		if let navigationController = self.navigationController {
			if let rootVC = navigationController.viewControllers.first {
				rootVC.navigationController?.setNavigationBarHidden(true, animated: animated)	// navigation bar 숨김
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
        tabBarViewModel.$isPlusButtonTappedInProfile
            .receive(on: DispatchQueue.main)
            .sink {
                print("감지2")
                if $0 {
                    let vc = AddViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                    self.tabBarViewModel.isPlusButtonTappedInProfile = false
                }
            }.store(in: &cancellable)
    }
    
	private func setAttribute() {
		// [view]
		view.backgroundColor = R.Color.gray100
		
		topArea = topArea.then {
			$0.backgroundColor = R.Color.gray900
		}
		
		profileHeaderView = profileHeaderView.then {
			$0.setData(email: userEmail)
			$0.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 222)
		}
		
		tableView = tableView.then {
			$0.delegate = self
			$0.dataSource = self
			$0.showsVerticalScrollIndicator = false
			$0.backgroundColor = R.Color.gray100
			$0.tableHeaderView = profileHeaderView
			$0.tableFooterView = profileFooterView
			$0.bounces = false			// TableView Scroll 방지
			$0.separatorInset.left = 24
			$0.separatorInset.right = 24
			$0.register(ProfileTableViewCell.self)
		}
	}
	
	private func setLayout() {
		view.addSubviews(topArea, tableView)

		topArea.snp.makeConstraints {
			$0.top.left.right.equalToSuperview()
			$0.height.equalTo(topSafeAreaInsets)
		}
		
		tableView.snp.makeConstraints {
			$0.top.equalTo(topArea.snp.bottom)
			$0.bottom.left.right.equalTo(view.safeAreaLayoutGuide)
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
		return 4
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.className, for: indexPath) as! ProfileTableViewCell

		if indexPath.row == 0 {
			cell.isUserInteractionEnabled = false // click disable
			DispatchQueue.main.async {
				cell.addAboveTheBottomBorderWithColor(color: R.Color.gray100)
			}
			cell.isNavigationHidden()
		} else {
			cell.setData(text: lableCellList[indexPath.row])
		}
		
		cell.backgroundColor = R.Color.gray100
		
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
			let vc = DataExportViewController(viewModel: viewModel)
			vc.hidesBottomBarWhenPushed = true	// TabBar Above
            navigationController?.pushViewController(vc, animated: true)
        case 3:
            let vc = ServiceViewController()
			vc.hidesBottomBarWhenPushed = true	// TabBar Above
            navigationController?.pushViewController(vc, animated: true)
		default:
			break
		}
	}
}
