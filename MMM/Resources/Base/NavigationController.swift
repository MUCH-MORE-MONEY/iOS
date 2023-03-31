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
		
		navigationBar.isTranslucent = false
		navigationBar.tintColor = UIColor.white
		navigationBar.barTintColor = R.Color.gray900
		navigationBar.scrollEdgeAppearance?.backgroundColor = R.Color.gray900
		navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
		
		if #available(iOS 15, *) {
			let appearance = UINavigationBarAppearance()
			appearance.configureWithOpaqueBackground()
			appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
			UINavigationBar.appearance().standardAppearance = appearance
			UINavigationBar.appearance().scrollEdgeAppearance = appearance
		}
	}
}
