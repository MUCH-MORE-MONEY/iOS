//
//  MMMAPI.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/08/29.
//

import Foundation
import Moya
import RxSwift

enum MMMAPI {
	// MARK: - V1 API
	
	// MARK: - Push
	case push(PushReqDto)
	case pushAgreeListSelect
	case pushAgreeUpdate(PushAgreeUpdateReqDto)
	
	// MARK: - Staticstics
	case getStaticsticsAverage(dateYM: String) // 월간 만족도 평균값
	case getStatisticsList(dateYM: String, valueScoreDvcd: String, limit: Int = 15, offset: Int = 0) // 만족도별 목록
	case getStatisticsCategory(dateYM: String, economicActivityDvcd: String)
	case getSelectedActivity(activityId: String)
	case getBudget(dateYM: String) // 월간 예산
	case getStatisticsSum(dateYM: String, economicActivityDvcd: String) // 해당 연월 기준 월간 경제활동 총합 조회
	case getStatisticsLast // 가장 최근 수정한 경제계획 조회 API
	case upsertEconomicPlan(info: APIParameters.UpsertEconomicPlanReqDto)
	
	// MARK: - Category Main
	//    case getAddCategoryList(CategoryListReqDto) //경제활동구분 코드 기준 카테고리별 월간 경제활동 목록 전체 조회
	case getCategoryList(CategoryListReqDto) // 경제활동구분 코드 기준 카테고리별 월간 경제활동 목록 전체 조회
	case getCategoryDetailList(CategoryDetailListReqDto) // 카테고리 코드별 월간 경제활동 목록 조회
	
	// MARK: - Category Edit
	case getCategoryEdit(CategoryEditReqDto)
	case getCategoryEditHeader(CategoryEditReqDto)
	case putCategoryEdit(PutCategoryEditReqDto)
	
	// MARK: - Profile
	case exportToExcel
	case getSummary
	case withdraw
	
	// MARK: - Widget
	case getWeely(WidgetReqDto)
	
	// MARK: - V2 API
	
	// MARK: - Staticstics
	case getDetailActivity(activityId: String)
}

extension MMMAPI: BaseNetworkService {
	
	/// baseURL
	var baseURL: URL {
		return URL(string: APIConstants.baseURL)!
	}
	
	/// router에 사용될 세부 경로
	var path: String {
		switch self {
			// MARK: - V1 API
		case .push:
			return "/push"
		case .pushAgreeListSelect:
			return "/push/agree/list/select"
		case .pushAgreeUpdate:
			return "/push/agree/update"
		case let .getStaticsticsAverage(dateYM):
			return "/economic_activity/\(dateYM)/average"
		case let .getStatisticsList(dateYM, valueScoreDvcd, _, _):
			return "/economic_activity/\(dateYM)/\(valueScoreDvcd)/list"
		case let .getStatisticsCategory(dateYM, economicActivityDvcd):
			return "/economic_activity/\(dateYM)/\(economicActivityDvcd)/upper-category/list"
		case .getSelectedActivity:
			return "/economic_activity/detail/select"
		case let .getBudget(dateYM):
			return "/v1/economic-plan/\(dateYM)"
		case let .getStatisticsSum(dateYM, economicActivityDvcd):
			return "/economic_activity/\(dateYM)/\(economicActivityDvcd)/sum"
		case .getStatisticsLast:
			return "/v1/economic-plan/latest-updated"
		case .upsertEconomicPlan:
			return "/v1/economic-plan"
		case let .getCategoryList(request):
			return "/economic_activity/\(request.dateYM)/\(request.economicActivityDvcd)/category/list"
		case let .getCategoryDetailList(request):
			return "/economic_activity/\(request.dateYM)/\(request.economicActivityDvcd)/category/detail/list"
		case let .getCategoryEdit(request):
			return "/economic-activity-category/list/\(request.economicActivityDvcd)"
		case let .getCategoryEditHeader(request):
			return "/economic-activity-category/list/upper/\(request.economicActivityDvcd)"
		case let .putCategoryEdit(request):
			return "/economic-activity-category/\(request.economicActivityDvcd)"
		case .exportToExcel:
			return "/economic_activity/excel/select"
		case .getSummary:
			return "/economic_activity/summary/select"
		case .withdraw:
			return "/login/delete"
		case let .getWeely(request):
			return "economic_activity​/\(request.dateYMD)/weekly"
			
			// MARK: - V2 API
		case .getDetailActivity:
			return "/v2/economic_activity/detail"
		}
	}
	
	/// 메서드 방식 선택
	var method: Moya.Method {
		switch self {
			// MARK: - V1 API
		case .push, .pushAgreeListSelect, .pushAgreeUpdate, .upsertEconomicPlan:
			return .post
		case .getStaticsticsAverage, .getStatisticsList, .getStatisticsCategory, .getBudget, .getStatisticsSum, .getSelectedActivity, .getStatisticsLast:
			return .get
		case .getCategoryList, .getCategoryDetailList, .getCategoryEdit, .getCategoryEditHeader:
			return .get
		case .putCategoryEdit:
			return .put
		case .exportToExcel, .getSummary, .withdraw:
			return .post
		case .getWeely:
			return .get
			
			// MARK: - V2 API
		case .getDetailActivity:
			return .get
		}
	}
	
	/// body parameter
	/// post - JSONEncoding.default
	/// get  -  URLEncoding.default
	/// parameter || body가 없을 경우 .requestPlain 설정
	var task: Moya.Task {
		switch self {
			// MARK: - V1 API
		case let .push(request):
			return .requestParameters(parameters: request.asDictionary, encoding: JSONEncoding.default)
		case .pushAgreeListSelect:
			return .requestPlain
		case let .pushAgreeUpdate(request):
			return .requestParameters(parameters: request.asDictionary, encoding: JSONEncoding.default)
		case let .upsertEconomicPlan(request):
			return .requestParameters(parameters: request.asDictionary, encoding: JSONEncoding.default)
		case .getStaticsticsAverage, .getStatisticsCategory, .getBudget, .getStatisticsSum, .getSelectedActivity, .getStatisticsLast:
			return .requestPlain
		case let .getStatisticsList(_, _, limit, offset):
			return .requestParameters(parameters: ["limit":limit, "offset":offset], encoding: URLEncoding.default)
		case .getCategoryList, .getCategoryEdit, .getCategoryEditHeader:
			return .requestPlain
		case let .putCategoryEdit(request):
			return .requestCustomJSONEncodable(request.data, encoder: .init())
		case let .getCategoryDetailList(request):
			return .requestParameters(parameters: ["economicActivityCategoryCd": request.economicActivityCategoryCd], encoding: URLEncoding.default)
		case .exportToExcel, .getSummary, .withdraw:
			return .requestPlain
		case .getWeely:
			return .requestPlain // get이지만 따로 필요한 값이 없다.
			
			// MARK: - V2 API
		case let .getDetailActivity(activityId):
			return .requestParameters(parameters: ["economicActivityNo" : activityId], encoding: URLEncoding.default)
		}
	}
	
	/// Header 전달
	/// nil 일 경우 헤더 요청하지 않음
	/// 값이 들어 있을 경우만 요청
	/// 옵셔널이지만 moya 내부적으로 헤더를 넘겨줌, 클라이언트에서 신경 쓸 필요 없음
	var headers: [String : String]? {
		guard let token = Constants.getKeychainValue(forKey: Constants.KeychainKey.token) else { return nil }
		return APIHeader.Default(token: token).asDictionary as? [String: String]
	}
}
