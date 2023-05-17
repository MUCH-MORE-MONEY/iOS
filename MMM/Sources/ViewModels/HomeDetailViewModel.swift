//
//  HomeDetailViewModel.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/05/11.
//

import Foundation
import Combine

final class HomeDetailViewModel {
    // MARK: - Property Wrapper
    @Published var detailActivity: SelectDetailResDto?
    
    // MARK: - Porperties
    private var cancellable: Set<AnyCancellable> = []

    
    func fetchDetailActivity(id: String) {
        guard Constants.getKeychainValue(forKey: Constants.KeychainKey.token) != nil else { return }
        
        APIClient.dispatch(
            APIRouter.SelectDetailReqDto(
                headers: APIHeader.Default(token: TempToken.token),
                body: APIParameters.SelectDetailReqDto(economicActivityNo: id)))
        .sink { error in
            switch error {
            case .failure(let data):
                switch data {
                case .error4xx(_):
                    print("400")
                    break
                case .error5xx(_):
                    print("500")
                    break
                case .decodingError(_):
                    print("디코딩에러")
                    break
                case .urlSessionFailed(_):
                    print("url 세션 에러")
                    break
                case .timeOut:
                    print("시간 초과")
                    break
                case .unknownError:
                    print("unknownError")
                    break
                default:
                    break
                }
            case .finished:
                break
            }
        } receiveValue: { [weak self] response in
            guard let self = self else { return }
            self.detailActivity = response
        }.store(in: &cancellable)
    }
}
