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
		
	private let profileView = ProfileView()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setup()		// 초기 셋업할 코드들
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

		profileView.setUp(email: "mmm1234@icloud.com")
		
		view.addSubviews(profileView)
	}
	
	private func setLayout() {
		// [view]
		profileView.snp.makeConstraints {
			$0.top.left.right.equalTo(view.safeAreaLayoutGuide)
			$0.height.equalTo(206)
		}
	}
}

private extension ProfileViewController {
}
