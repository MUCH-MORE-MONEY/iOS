//
//  Ex+NSObject.swift
//  MMM
//
//  Created by geonhyeong on 2023/03/29.
//

import Foundation

public extension NSObject {

	var className: String {
		return String(describing: type(of: self))
	}

	class var className: String {
		return String(describing: self)
	}
}
