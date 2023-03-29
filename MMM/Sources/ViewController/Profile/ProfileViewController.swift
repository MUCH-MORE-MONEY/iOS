//
//  ViewController.swift
//  MMM
//
//  Created by geonhyeong on 2023/03/28.
//

import UIKit
import Then
import SnapKit

// 상속하지 않으려면 final 꼭 붙이기
final class ProfileViewController: UIViewController {
		
	private lazy var topArea = UIView()
	
	private lazy var profileView = ProfileView()
	
	private lazy var profileFooterView = ProfileFooterView()
	
	private lazy var tableView = UITableView()
	
	private lazy var lableCellList = ["계정 관리", "데이터 내보내기", "문의 및 서비스 약관", "앱 버전"]

	override func viewDidLoad() {
		super.viewDidLoad()
		setup()		// 초기 셋업할 코드들
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent // status text color 변경
	}
}

//MARK: - Style & Layouts
private extension ProfileViewController {
	
	private func setup() {
		// 초기 셋업할 코드들
		setAttribute()
		setLayout()
	}
	
	private func setAttribute() {
		// [view]
		view.backgroundColor = R.Color.gray100
		
		topArea = topArea.then {
			$0.backgroundColor = R.Color.gray900
		}
		
		profileView = profileView.then {
			$0.setUp(email: "mmm1234@icloud.com")
			$0.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 206)
		}
		
		tableView = tableView.then {
			$0.delegate = self
			$0.dataSource = self
			$0.showsVerticalScrollIndicator = false
			$0.backgroundColor = R.Color.gray100
			$0.tableHeaderView = profileView
			$0.tableFooterView = profileFooterView
			$0.separatorInset = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
			$0.register(ProfileTableViewCell.self)
		}
				
		view.addSubviews(topArea, tableView)
	}
	
	private func setLayout() {
		// [view]
		topArea.snp.makeConstraints {
			var topSafeAreaInsets: CGFloat = 0.0
			let scenes = UIApplication.shared.connectedScenes
			let windowScene = scenes.first as? UIWindowScene
			if let hasWindowScene = windowScene {
				topSafeAreaInsets = hasWindowScene.windows.first?.safeAreaInsets.top ?? 0
			}
			$0.top.left.right.equalToSuperview()
			$0.top.height.equalTo(topSafeAreaInsets)
		}
		
		tableView.snp.makeConstraints {
			$0.top.bottom.equalTo(view.safeAreaLayoutGuide)
			$0.left.right.equalTo(view.safeAreaLayoutGuide)
		}
	}
}

// MARK: - UITableView DataSource
extension ProfileViewController: UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 44
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 3
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.className, for: indexPath) as! ProfileTableViewCell

		cell.setUp(text: lableCellList[indexPath.row])
		cell.backgroundColor = R.Color.gray100
		
		return cell
	}
}

// MARK: - UITableView Delegate
extension ProfileViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		// 셀 터치시 회색 표시 없애기
		tableView.deselectRow(at: indexPath, animated: true)
	}
}
