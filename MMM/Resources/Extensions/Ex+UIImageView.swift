//
//  Ex+UIImageView.swift
//  MMM
//
//  Created by geonhyeong on 2023/05/02.
//

import UIKit
import Kingfisher

extension UIImageView {
	// 비동기 처리
	func setImage(urlStr: String, defaultImage: UIImage?) {
		ImageCache.default.retrieveImage(forKey: urlStr, options: nil) { result in
			switch result {
			case .success(let value):
				if let image = value.image {
					//캐시가 존재하는 경우
					self.image = image
				} else {
					//캐시가 존재하지 않는 경우
					guard let url = URL(string: urlStr) else {
						self.image = defaultImage
						return
					}
					let resource = ImageResource(downloadURL: url, cacheKey: urlStr)
					self.kf.setImage(with: resource, options: [.transition(.fade(1.2))]) // 이미지를 가져오는 1.2동안 애니메이션
				}
			case .failure:
				self.image = defaultImage
			}
		}
	}
}
