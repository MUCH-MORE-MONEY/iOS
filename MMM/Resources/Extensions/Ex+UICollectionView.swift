//
//  Ex+UICollectionView.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/25.
//

import UIKit

public extension UICollectionView {
	func register<T: UICollectionViewCell>(_ cellClass: T.Type) {
		let reuseIdentifier = cellClass.className
		register(cellClass, forCellWithReuseIdentifier: reuseIdentifier)
	}
	
	func register<T: UICollectionReusableView>(_ viewClass: T.Type, forSupplementaryViewOfKind elementKind: String) {
		let reuseIdentifier = viewClass.className
		register(viewClass, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: reuseIdentifier)
	}
	
	func registerNib<T: UICollectionViewCell>(_ cellClass: T.Type) {
		let reuseIdentifier = cellClass.className
		register(UINib(nibName: reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
	}
}
