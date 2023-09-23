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
	// MARK: - Push
	case push(PushReqDto)
	case pushAgreeListSelect
	case pushAgreeUpdate(PushAgreeUpdateReqDto)
	
	// MARK: - Staticstics
	case getStaticsticsAverage(dateYM: String) // 월간 만족도 평균값
	case getStatisticsList(dateYM: String, valueScoreDvcd: String, limit: Int = 15, offset: Int = 0) // 만족도별 목록
	case getStatisticsCategory(dateYM: String, economicActivityDvcd: String)
	
	// MARK: - Staticstics Category
	case getCategory(CategoryReqDto)
	case getCategoryHeader(CategoryReqDto)
	case getCategoryList(CategoryListReqDto) // 카테고리 코드별 월간 경제활동 목록 조회

	// MARK: - Profile
	case exportToExcel
	case getSummary
	case withdraw
}

extension MMMAPI: BaseNetworkService {
	
	/// baseURL
	var baseURL: URL {
		return URL(string: APIConstants.baseURL)!
	}
	
	/// router에 사용될 세부 경로
	var path: String {
		switch self {
		case .push:
			return "/push"
		case .pushAgreeListSelect:
			return "/push/agree/list/select"
		case .pushAgreeUpdate:
			return "/push/agree/update"
		case .getStaticsticsAverage(let dateYM):
			return "/economic_activity/\(dateYM)/average"
		case .getStatisticsList(let dateYM, let valueScoreDvcd, _, _):
			return "/economic_activity/\(dateYM)/\(valueScoreDvcd)/list"
		case .getStatisticsCategory(let dateYM, let economicActivityDvcd):
			return "/economic_activity/\(dateYM)/\(economicActivityDvcd)/upper-category/list"
		case .getCategory(let request):
			return "/economic-activity-category/list/\(request.economicActivityDvcd)"
		case .getCategoryHeader(let request):
			return "/economic-activity-category/list/upper/\(request.economicActivityDvcd)"
		case .getCategoryList(let request):
			return "/economic-activity-category/\(request.dateYM)/category/\(request.economicActivityCategoryCd)/list"
		case .exportToExcel:
			return "/economic_activity/excel/select"
		case .getSummary:
			return "/economic_activity/summary/select"
		case .withdraw:
			return "/login/delete"
		}
	}
	
	/// 메서드 방식 선택
	var method: Moya.Method {
		switch self {
		case .push, .pushAgreeListSelect, .pushAgreeUpdate:
			return .post
		case .getStaticsticsAverage, .getStatisticsList, .getStatisticsCategory:
			return .get
		case .getCategory, .getCategoryHeader, .getCategoryList:
			return .get
		case .exportToExcel, .getSummary, .withdraw:
			return .post
		}
	}
	
	/// body parameter
	/// post - JSONEncoding.default
	/// get  -  URLEncoding.default
	/// parameter || body가 없을 경우 .requestPlain 설정
	var task: Moya.Task {
		switch self {
		case .push(let request):
			return .requestParameters(parameters: request.asDictionary, encoding: JSONEncoding.default)
		case .pushAgreeListSelect:
			return .requestPlain
		case .pushAgreeUpdate(let request):
			return .requestParameters(parameters: request.asDictionary, encoding: JSONEncoding.default)
		case .getStaticsticsAverage, .getStatisticsCategory:
			return .requestPlain
		case .getStatisticsList(_, _, let limit, let offset):
			return .requestParameters(parameters: ["limit":limit, "offset":offset], encoding: URLEncoding.default)
		case .getCategory, .getCategoryHeader, .getCategoryList:
			return .requestPlain
		case .exportToExcel, .getSummary, .withdraw:
			return .requestPlain
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
