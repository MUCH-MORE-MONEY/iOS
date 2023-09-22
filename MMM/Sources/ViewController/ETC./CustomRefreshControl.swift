//
//  CustomRefreshControl.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/22.
//

import UIKit

final class RefreshControl: UIRefreshControl {
	override func layoutSubviews() {
		super.layoutSubviews()
		let originalFrame = frame
		frame = originalFrame
	}
}
