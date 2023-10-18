//
//  AddCategoryViewModel.swift
//  MMM
//
//  Created by Park Jungwoo on 10/18/23.
//

import UIKit
import Combine

final class AddCategoryViewModel {
    // MARK: - API Request를 위한 Property Wrapper
    @Published var categoryListResponse: CategoryListResDto?
    
    // MARK: - Porperties
    private var cancellable: Set<AnyCancellable> = []
    
    func getCategoryList(date: String, dvcd: String) {
        guard let token = Constants.getKeychainValue(forKey: Constants.KeychainKey.token) else { return }
        
        APIClient.dispatch(
            APIRouter.CategoryListReqDto(
                headers: APIHeader.Default(token: token),
                dateYM: date,
                dvcd: dvcd))
        .sink { data in
            switch data {
            case .failure(_):
                break
            case.finished:
                break
            }
        } receiveValue: { response in
            print(response)
            self.categoryListResponse = response
        }
        .store(in: &cancellable)
    }
}
