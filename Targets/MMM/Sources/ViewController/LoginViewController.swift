//
//  LoginViewController.swift
//  MMM
//
//  Created by geonhyeong on 2023/03/27.
//  Copyright © 2023 Lab.M. All rights reserved.
//

import UIKit
import SnapKit
import Then

final class LoginViewController: UIViewController {
	
	//MARK: Property
	var lblTitle = UILabel()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setAttribute()
//		layout()
		// Do any additional setup after loading the view.
	}
	
	private func setAttribute() {
		lblTitle = lblTitle.then {
			$0.text = "Test"
//			$0.font = R.Font.
			$0.textColor = .label
		}

	}
	
//	private func layout() {
//		view.addSubviews(lblTitle)
//
//		lblTitle.snp.makeConstraints {
//			$0.centerX.equalTo(view.safeAreaLayoutGuide)
//			$0.top.equalTo(view.safeAreaLayoutGuide).inset(45)
//		}
//	}
	

	/*
	// MARK: - Navigation

	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// Get the new view controller using segue.destination.
		// Pass the selected object to the new view controller.
	}
	*/

}
