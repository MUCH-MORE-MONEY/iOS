//
//  OnboardingItem.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/03/31.
//

import UIKit
import Then

struct OnboardingItem {
    let image: UIImage
    let mainLabel1: String
    let mainLabel2: String
    let subLabel: String

    var imageView: UIImageView {
        let imageView = UIImageView().then {
            $0.contentMode = .scaleAspectFit
            $0.layer.masksToBounds = true
            $0.image = image
            $0.backgroundColor = R.Color.gray900
        }
        return imageView
    }
}
