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
    func getStatisticsAverage(_ dateYM: String) -> Observable<(StatisticsAvgResDto, Error?)>
	func getStatisticsList(dateYM: String, valueScoreDvcd: String, limit: Int, offset: Int) -> Observable<(StatisticsListResDto, Error?)>
	func getStatisticsCategory(dateYM: String, economicActivityDvcd: String) -> Observable<(StatisticsCategoryResDto, Error?)>
	func getBudget(dateYM: String) -> Observable<(StatisticsBudgetResDto, Error?)>
	func getStatisticsSum(dateYM: String, economicActivityDvcd: String) -> Observable<(StatisticsSumResDto, Error?)>
	func getStatisticsLast() -> Observable<(StatisticsLastResDto, Error?)>
	func upsertEconomicPlan(request: APIParameters.UpsertEconomicPlanReqDto) -> Observable<(UpsertEconomicPlanResDto, Error?)>
	
    // MARK: - Statistics Detail
    func getDetailActivity(_ aactivityIdc: String) -> Observable<(SelectDetailResDto, Error?)>
    
	// MARK: - Category Main 요청 API
	func getCategoryList(_ request: CategoryListReqDto) -> Observable<(CategoryListResDto, Error?)>
	func getCategoryDetailList(_ request: CategoryDetailListReqDto) -> Observable<(CategoryDetailListResDto, Error?)>

	// MARK: - Category Edit 요청 API
    func getCategoryEdit(_ request: CategoryEditReqDto) -> Observable<(CategoryEditResDto, Error?)>
	func getCategoryEditHeader(_ request: CategoryEditReqDto) -> Observable<(CategoryEditHeaderResDto, Error?)>
	func putCategoryEdit(_ request: PutCategoryEditReqDto) -> Observable<(CategoryEditResDto, Error?)>
    
    // MARK: - Profile 요청 API
    func exportToExcel() -> Observable<(ExportResDto, Error?)>
    func withdraw() -> Observable<(WithdrawResDto, Error?)>
    func getSummary() -> Observable<(SummaryResDto, Error?)>
	
	// MARK: - Widget 요청 API
	func getWeekly(_ request: WidgetReqDto) -> Observable<(WidgetResDto, Error?)>
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
	func getStatisticsAverage(_ dateYM: String) -> Observable<(StatisticsAvgResDto, Error?)> {
		return provider().request(MMMAPI.getStaticsticsAverage(dateYM: dateYM), type: StatisticsAvgResDto.self).asObservable()
	}
	
	// 통계 만족도별 List
	func getStatisticsList(dateYM: String, valueScoreDvcd: String, limit: Int, offset: Int) -> RxSwift.Observable<(StatisticsListResDto, Error?)> {
		return provider().request(MMMAPI.getStatisticsList(dateYM: dateYM, valueScoreDvcd: valueScoreDvcd, limit: limit, offset: offset), type: StatisticsListResDto.self).asObservable()
	}
	
	// 통계 카테고리 Bar List
	func getStatisticsCategory(dateYM: String, economicActivityDvcd: String) -> RxSwift.Observable<(StatisticsCategoryResDto, Error?)> {
		return provider().request(MMMAPI.getStatisticsCategory(dateYM: dateYM, economicActivityDvcd: economicActivityDvcd), type: StatisticsCategoryResDto.self).asObservable()
	}
    
    // v2 통계에서 detail cell을 선택했을 경우 activityId를 가지고 fetch
    func getDetailActivity(_ activityId: String) -> Observable<(SelectDetailResDto, Error?)> {
        return provider().request(MMMAPI.getDetailActivity(activityId: activityId), type: SelectDetailResDto.self).asObservable()
    }
	
	// 해당 연월 기준 경제계획 조회 API
	func getBudget(dateYM: String) -> RxSwift.Observable<(StatisticsBudgetResDto, (any Error)?)> {
		return provider().request(MMMAPI.getBudget(dateYM: dateYM), type: StatisticsBudgetResDto.self).asObservable()
	}
	
	func getStatisticsSum(dateYM: String, economicActivityDvcd: String) -> RxSwift.Observable<(StatisticsSumResDto, (any Error)?)> {
		return provider().request(MMMAPI.getStatisticsSum(dateYM: dateYM, economicActivityDvcd: economicActivityDvcd), type: StatisticsSumResDto.self).asObservable()
	}

	// 가장 최근 수정한 경제계획 조회 API
	func getStatisticsLast() -> RxSwift.Observable<(StatisticsLastResDto, Error?)> {
		return provider().request(MMMAPI.getStatisticsLast, type: StatisticsLastResDto.self).asObservable()
	}
	
	func upsertEconomicPlan(request: APIParameters.UpsertEconomicPlanReqDto) -> RxSwift.Observable<(UpsertEconomicPlanResDto, Error?)> {
		return provider().request(MMMAPI.upsertEconomicPlan(info: request), type: UpsertEconomicPlanResDto.self).asObservable()
	}

	// MARK: - Category Main 요청 API
	// 경제활동구분 코드 기준 카테고리별 월간 경제활동 목록 전체 조회
	func getCategoryList(_ request: CategoryListReqDto) -> RxSwift.Observable<(CategoryListResDto, Error?)> {
		return provider().request(MMMAPI.getCategoryList(request), type: CategoryListResDto.self).asObservable()
	}
	
	// 카테고리 코드별 월간 경제활동 목록 조회
	func getCategoryDetailList(_ request: CategoryDetailListReqDto) -> RxSwift.Observable<(CategoryDetailListResDto, Error?)> {
		return provider().request(MMMAPI.getCategoryDetailList(request), type: CategoryDetailListResDto.self).asObservable()
	}
	
	// MARK: - Category Edit 요청 API
	// 경제활동카테고리 목록 조회 API
	func getCategoryEdit(_ request: CategoryEditReqDto) -> RxSwift.Observable<(CategoryEditResDto, Error?)> {
		return provider().request(MMMAPI.getCategoryEdit(request), type: CategoryEditResDto.self).asObservable()
	}
	
	// 경제활동상위카테고리 목록 조회 API
	func getCategoryEditHeader(_ request: CategoryEditReqDto) -> RxSwift.Observable<(CategoryEditHeaderResDto, Error?)> {
		return provider().request(MMMAPI.getCategoryEditHeader(request), type: CategoryEditHeaderResDto.self).asObservable()
	}
	
	// 경제활동 카테고리 전체 수정 API
	func putCategoryEdit(_ request: PutCategoryEditReqDto) -> RxSwift.Observable<(CategoryEditResDto, Error?)> {
		return provider().request(MMMAPI.putCategoryEdit(request), type: CategoryEditResDto.self).asObservable()
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
	
	// MARK: - Weekly 요청 API
	func getWeekly(_ request: WidgetReqDto) -> RxSwift.Observable<(WidgetResDto, Error?)> {
		return provider().request(MMMAPI.getWeely(request), type: WidgetResDto.self).asObservable()
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
