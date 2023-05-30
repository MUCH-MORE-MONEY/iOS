//
//  Ex+UILabel.swift
//  MMM
//
//  Created by geonhyeong on 2023/05/29.
//

import UIKit
import SnapKit

extension UILabel {
	/// 오른쪽에 imageView를 넣는 방법
	func addImageViewOnRight(image: UIImage?, offset: CGFloat = 4.0) {
		guard let image = image else { return }
		let imageView = UIImageView(image: image)
		imageView.contentMode = .scaleAspectFit
		
		addSubview(imageView)
		
		imageView.snp.makeConstraints {
			$0.leading.equalTo(self.snp.trailing).offset(offset)
			$0.centerY.equalToSuperview()
			$0.width.equalTo(image.size.width)
			$0.height.equalTo(image.size.height)
		}
		
		self.layoutIfNeeded()
	}
}
