//
//  TabItem.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/04/18.
//

import UIKit

enum TabItem: String {
    case home
    case add
    case profile
    
    var image: UIImage? {
        switch self {
        case .home:
            return R.Icon.iconMoneyInActive
        case .add:
            return R.Icon.iconPlus
        case .profile:
            return R.Icon.iconMypageInActive
        }
    }
    
    var selectedImage: UIImage? {
        switch self {
        case .home:
            return R.Icon.iconMoneyActive
        case .add:
            return R.Icon.iconPlus
        case .profile:
            return R.Icon.iconMypageActive
        }
    }
}
