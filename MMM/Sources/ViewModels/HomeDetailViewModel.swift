//
//  HomeDetailViewModel.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/05/11.
//

import UIKit
import Combine

final class HomeDetailViewModel {
    // MARK: - Property Wrapper
    @Published var detailActivity: SelectDetailResDto?
    @Published var hasImage = false
    @Published var mainImage: UIImage?
    @Published var isShowToastMessage = false
    @Published var isLoading = false
    // MARK: - Porperties
    private var cancellable: Set<AnyCancellable> = []

    
    func fetchDetailActivity(id: String) {
        guard let token = Constants.getKeychainValue(forKey: Constants.KeychainKey.token) else { return }
        
        APIClient.dispatch(
            APIRouter.SelectDetailReqDto(
                headers: APIHeader.Default(token: token),
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
            self.isLoading = true
        }.store(in: &cancellable)
    }
}
