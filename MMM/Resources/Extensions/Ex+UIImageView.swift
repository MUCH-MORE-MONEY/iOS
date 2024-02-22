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
		self.kf.indicatorType = .activity
		let retryStrategy = DelayRetryStrategy(maxRetryCount: 2, retryInterval: .seconds(3)) // 이미지 로드 실패 시 재시도 - DelayRetryStrategy 인스턴스를 .retryStraregy() 생성자로 주입

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
                    let resource = KF.ImageResource(downloadURL: url, cacheKey: urlStr)
					// 이미지를 가져오는 1.2동안 애니메이션 (.fade) 제거
					self.kf.setImage(with: resource, options: [.retryStrategy(retryStrategy), .transition(.none), .forceTransition], completionHandler: { res in
						switch res {
						case .success(_): break
						case .failure: self.image = defaultImage
						}
					})
				}
			case .failure:
				self.image = defaultImage
			}
		}
	}
    
    func setImage(urlStr: String, defaultImage: UIImage?, completion: @escaping () -> ()) {
        self.kf.indicatorType = .activity
        let retryStrategy = DelayRetryStrategy(maxRetryCount: 2, retryInterval: .seconds(3)) // 이미지 로드 실패 시 재시도 - DelayRetryStrategy 인스턴스를 .retryStraregy() 생성자로 주입

        ImageCache.default.retrieveImage(forKey: urlStr, options: nil) { result in
            switch result {
            case .success(let value):
                if let image = value.image {
                    //캐시가 존재하는 경우
                    self.image = image
                    completion()
                } else {
                    //캐시가 존재하지 않는 경우
                    guard let url = URL(string: urlStr) else {
                        self.image = defaultImage
                        return
                    }
                    let resource = KF.ImageResource(downloadURL: url, cacheKey: urlStr)
                    // 이미지를 가져오는 1.2동안 애니메이션 (.fade) 제거
                    self.kf.setImage(with: resource, options: [.retryStrategy(retryStrategy), .transition(.none), .forceTransition], completionHandler: { res in
                        switch res {
                        case .success(_): break
                        case .failure: self.image = defaultImage
                        }
                    })
                }
            case .failure:
                self.image = defaultImage
            }
        }
    }
}
