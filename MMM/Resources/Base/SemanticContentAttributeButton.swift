//
//  SemanticContentAttributeButton.swift
//  MMM
//
//  Created by geonhyeong on 2023/05/18.
//

import UIKit

/// 이미지와 텍스트를 정렬해서 넣어주는 button
final class SemanticContentAttributeButton: UIButton {
	// Error 해결 - Push 후 dismiss에 대한 문제
	override func layoutSubviews() {
		super.layoutSubviews()
		self.semanticContentAttribute = .forceRightToLeft
	}
}
