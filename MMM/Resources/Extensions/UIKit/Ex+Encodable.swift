//
//  Ex+Encodable.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/05/01.
//

import Foundation

extension Encodable {
    /// Encodable 객체를 JSON 형태로 반환해주기 위한 계산 프로퍼티
    var asDictionary: [String: Any] {
        guard let data = try? JSONEncoder().encode(self) else { return [:] }

        guard let dictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            return [:]
        }
        return dictionary
    }
}
