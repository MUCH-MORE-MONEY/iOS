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
protocol MMMAPIServiceble: BaseAPIService {
    // MARK: - Push 요청 API
    func push(_ request: PushReqDto) -> Observable<(PushResDto, Error?)>
    func pushAgreeListSelect() -> Observable<(PushAgreeListSelectResDto, Error?)>
    func pushAgreeUpdate(_ request: PushAgreeUpdateReqDto) -> Observable<(PushAgreeUpdateResDto, Error?)>
	
    // MARK: - Statistics 요청 API
    func getStatisticsAverage(_ dateYM: String) -> Observable<(StatisticsResDto, Error?)>

    // MARK: - Staticstics Category 요청 API
    func getCategory(_ request: CategoryReqDto) -> Observable<(CategoryResDto, Error?)>

    // MARK: - Profile 요청 API
    func exportToExcel() -> Observable<(ExportResDto, Error?)>
    func withdraw() -> Observable<(WithdrawResDto, Error?)>
    func getSummary() -> Observable<(SummaryResDto, Error?)>
}

// MARK:
struct MMMAPIService: MMMAPIServiceble {
    typealias APIType = MMMAPI
    
    func provider() -> Moya.MoyaProvider<MMMAPI> {
        return MoyaProvider<APIType>()
    }
    
    // MARK: - Push 요청 API
    func push(_ request: PushReqDto) -> Observable<(PushResDto, Error?)> {
        return provider().request(MMMAPI.push(request), type: PushResDto.self).asObservable()
    }
    
    func pushAgreeListSelect() -> Observable<(PushAgreeListSelectResDto, Error?)> {
        return provider().request(MMMAPI.pushAgreeListSelect, type: PushAgreeListSelectResDto.self).asObservable()
    }
    
    func pushAgreeUpdate(_ request: PushAgreeUpdateReqDto) -> Observable<(PushAgreeUpdateResDto, Error?)> {
        return provider().request(MMMAPI.pushAgreeUpdate(request), type: PushAgreeUpdateResDto.self).asObservable()
	}
	
	// MARK: - Statistics 요청 API
	// 통계 만족도 평균 요청
	func getStatisticsAverage(_ dateYM: String) -> Observable<(StatisticsResDto, Error?)> {
		return provider().request(MMMAPI.getStaticsticsAverage(dateYM: dateYM), type: StatisticsResDto.self).asObservable()
	}
	
	// MARK: - Staticstics Category 요청 API
	func getCategory(_ request: CategoryReqDto) -> RxSwift.Observable<(CategoryResDto, Error?)> {
		return provider().request(MMMAPI.getCategory(request), type: CategoryResDto.self).asObservable()
	}
	
	// MARK: - Profile 요청 API
	func exportToExcel() -> RxSwift.Observable<(ExportResDto, Error?)> {
		return provider().request(MMMAPI.exportToExcel, type: ExportResDto.self).asObservable()
	}
	
	func getSummary() -> RxSwift.Observable<(SummaryResDto, Error?)> {
		return provider().request(MMMAPI.getSummary, type: SummaryResDto.self).asObservable()
	}
	
	func withdraw() -> RxSwift.Observable<(WithdrawResDto, Error?)> {
		return provider().request(MMMAPI.exportToExcel, type: WithdrawResDto.self).asObservable()
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
