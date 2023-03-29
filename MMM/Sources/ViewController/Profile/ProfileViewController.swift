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
	
	private let profileView = ProfileView()
	
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
		
		profileView.setUp(email: "mmm1234@icloud.com")
		
		view.addSubviews(topArea, profileView)
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
		
		profileView.snp.makeConstraints {
			$0.top.left.right.equalTo(view.safeAreaLayoutGuide)
			$0.height.equalTo(206)
		}
	}
}

private extension ProfileViewController {
}
