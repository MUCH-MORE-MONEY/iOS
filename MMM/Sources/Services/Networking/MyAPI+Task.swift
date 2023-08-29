//
//  MyAPI+Task.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/08/29.
//

import Foundation
import Moya

extension MyAPI {
    func getTask() -> Task {
        switch self {
        case .push(let request):
            return .requestParameters(parameters: request.toDictionary(), encoding: URLEncoding.queryString)
        }
    }
}

extension Encodable {
    func toDictionary() -> [String: Any] {
        do {
            let jsonEncoder = JSONEncoder()
            let encodedData = try jsonEncoder.encode(self)
            
            let dictionaryData = try JSONSerialization.jsonObject(
                with: encodedData,
                options: .allowFragments
            ) as? [String: Any]
            return dictionaryData ?? [:]
        } catch {
            return [:]
        }
    }
}
