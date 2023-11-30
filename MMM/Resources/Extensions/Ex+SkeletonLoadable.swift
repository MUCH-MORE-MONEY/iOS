//
//  SkeletonLoadable.swift
//  MMM
//
//  Created by geonhyeong on 11/29/23.
//

import UIKit

protocol SkeletonLoadable {}

extension SkeletonLoadable {
	func makeAnimationGroup(previousGroup: CAAnimationGroup? = nil) -> CAAnimationGroup {
		let animDuration: CFTimeInterval = 1.5
		let anim1 = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.backgroundColor))
		anim1.fromValue = R.Color.gray200.cgColor
		anim1.toValue = R.Color.gray400.cgColor
		anim1.duration = animDuration
		anim1.beginTime = 0.0

		let anim2 = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.backgroundColor))
		anim2.fromValue = R.Color.gray400.cgColor
		anim2.toValue = R.Color.gray200.cgColor
		anim2.duration = animDuration
		anim2.beginTime = anim1.beginTime + anim1.duration

		let group = CAAnimationGroup()
		group.animations = [anim1, anim2]
		group.repeatCount = .greatestFiniteMagnitude // infinite
		group.duration = anim2.beginTime + anim2.duration
		group.isRemovedOnCompletion = false

		if let previousGroup = previousGroup {
			// 효과를 위한 그룹을 0.33초씩 offset
			group.beginTime = previousGroup.beginTime + 0.33
		}

		return group
	}
}
