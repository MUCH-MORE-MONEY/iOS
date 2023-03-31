//
//  NavigationController.swift
//  MMM
//
//  Created by geonhyeong on 2023/03/30.
//

import UIKit

class NavigationController: UINavigationController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationBar.isTranslucent = false	// 반투명
		navigationBar.tintColor = UIColor.white
		navigationBar.barTintColor = R.Color.gray900
		navigationBar.backgroundColor = R.Color.gray900
		navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: R.Font.title3]
		
		if #available(iOS 15, *) {
			let appearance = UINavigationBarAppearance()
			appearance.configureWithOpaqueBackground()
			appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: R.Font.title3]
			appearance.backgroundColor = R.Color.gray900

			UINavigationBar.appearance().standardAppearance = appearance
			UINavigationBar.appearance().scrollEdgeAppearance = appearance
		}
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent // status text color 변경
	}
}