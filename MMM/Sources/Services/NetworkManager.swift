//
//  NetworkManager.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/04/27.
//

import Foundation
import Combine

enum NetworkError: Error {
    case invalidURL
    case responseError
    case unknown
}

// network 에러 처리 description
extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("Invalid URL", comment: "Invalid URL")
        case .responseError:
            return NSLocalizedString("Unexpected status code", comment: "Invalid response")
        case .unknown:
            return NSLocalizedString("Unknown error", comment: "Unknown error")
        }
    }
}

final class NetworkManager {
    static let shared = NetworkManager()
    
    private var cancellables = Set<AnyCancellable>()
    private let baseURL = APIConstants.baseURL
    
    
    
    func fetchData() {
        let urlStr = APIConstants.baseURL
        guard let url = URL(string: urlStr) else { return }
        //dataTaskPublsiher는 URLSession에서 제공하는 Publisher입니다.
        let cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [LoginResponse].self, decoder: JSONDecoder()) //전달받은 데이터를 JSON형식으로 Decode합니다.
            .replaceError(with: []) //에러가 발생할경우 에러를 전달하지않습니다.
            .eraseToAnyPublisher()
            .sink(receiveValue: { posts in
                print("전달받은 데이터는 총 \(posts.count)개 입니다.")
            })
    }
}
