//
//  MyAPI+Method.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/08/29.
//

import Foundation
import Moya

extension MyAPI {
    func getMethod() -> Moya.Method {
        switch self {
        case .push:
            return .get
        }
    }
}
