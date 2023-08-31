//
//  MMMProvider.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/08/29.
//

import Foundation
import Moya
import RxSwift


// MARK: NetworkStatus and NetworkError
enum NetworkStatusType: Int {
    case success = 200
    case notFound = 404
}

enum NetworkErrorType: Error {
    case wrongURL
    case decodeError
}

// MARK: Result Data
struct EmptyResult: Decodable { }
struct NetworkResult<T: Decodable>: Decodable {
    var result: T
    var status: Int
    var message: String?
}

struct NetworkFailResult: Decodable {
    var message: String
    var errorCode: Int
}

// MARK: API 구현부 인터페이스에서 상속 받을 때 사용
protocol BaseAPIService {
    associatedtype APIType: TargetType
    func provider() -> MoyaProvider<APIType>
    //func handleResultData<T: Decodable>(T: T.Type, result: Result<Response, MoyaError>) -> RxSwift.Single<(T, Error?)>
}
extension BaseAPIService {
    
//    func handleResultData<T: Decodable>(T: T.Type, result: Result<Response, MoyaError>) -> RxSwift.Single<(T, Error?)> {
//
//
//    }
}

// MARK: 사용할 API 정의
protocol UserAPIServiceble: BaseAPIService {
    func push(_ request: PushReqDto) -> Observable<(PushResDto, Error?)>
}

// MARK:
struct MMMAPIService: UserAPIServiceble {

    typealias APIType = MMMAPI
    
    func provider() -> Moya.MoyaProvider<MMMAPI> {
        return MoyaProvider<APIType>()
    }
    
    func push(_ request: PushReqDto) -> Observable<(PushResDto, Error?)> {
        return provider().request(MMMAPI.push(request), type: PushResDto.self).asObservable()
    }
}

// MARK: MoyaProvider 네트워크 공통 로직
extension MoyaProvider {
    func request<T: Decodable>(_ target: TargetType, type: T.Type) -> RxSwift.Single<(T, Error?)> {
        let single = Single<(T, Error?)>.create { single in
            self.request(target as! Target) { result in
                switch result {
                case .success(let response):
                    guard response.statusCode == NetworkStatusType.success.rawValue else {
                        single(.failure(NetworkErrorType.wrongURL))
                        return
                    }
                    let data = response.data
                    
                    guard let json = try? JSONDecoder().decode(T.self, from: data) else {
                        single(.failure(NetworkErrorType.decodeError))
                        return
                    }
                    
                    single(.success((json, nil)))
                    
                case .failure(let failure):
                    single(.failure( failure))
                }
            }
            
            return Disposables.create()
        }
        
        return single
    }
}
