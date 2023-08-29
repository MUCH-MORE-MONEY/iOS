//
//  MyAPI+Path.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/08/29.
//

import Foundation

extension MyAPI {
    func getPath() -> String {
        switch self {
        case .push:
            return "/push"
        }
    }
}
