//
//  Ex+UIScreen.swift
//  MMM
//
//  Created by geonhyeong on 2023/06/13.
//

import UIKit

extension UIScreen {
	static var width: CGFloat {
		get {
			return UIScreen.main.bounds.size.width
		}
	}
	
	static var height: CGFloat {
		get {
			return UIScreen.main.bounds.size.height
		}
	}
}
