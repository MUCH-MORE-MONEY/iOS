//
//  UIStackView.swift
//  MMM
//
//  Created by geonhyeong on 2023/04/27.
//

import UIKit

public extension UIStackView {
	func addArrangedSubviews(_ views: UIView...) {
		views.forEach { view in
			view.translatesAutoresizingMaskIntoConstraints = false
			addArrangedSubview(view)
		}
	}
}
