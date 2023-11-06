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
    @Published var categoryList: [Category] = []
    @Published var selectedCategoryID: String = ""
    @Published var selectedCategoryName: String = ""
    @Published var isLoading = true
    
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
            case .failure(let error):
                print(error)
                break
            case.finished:
                break
            }
        self.isLoading = false
        } receiveValue: { [weak self] response in
            guard let self = self else { return }
            self.categoryList = response.data
        }
        .store(in: &cancellable)
    }
}
