//
//  Ex+UITableView.swift
//  MMM
//
//  Created by geonhyeong on 2023/03/29.
//

import UIKit

public extension UITableView {
	func register<T: UITableViewCell>(_ cellClass: T.Type) {
		let reuseIdentifier = cellClass.className
		register(cellClass, forCellReuseIdentifier: reuseIdentifier)
	}
	
	func registerNib<T: UICollectionViewCell>(_ cellClass: T.Type) {
		let reuseIdentifier = cellClass.className
		register(UINib(nibName: reuseIdentifier, bundle: nil), forCellReuseIdentifier: reuseIdentifier)
	}
}
