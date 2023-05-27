//
//  EditActivityViewModel.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/05/23.
//

import UIKit
import Photos
import Combine

final class EditActivityViewModel {
    // MARK: - Property Wrapper
    @Published var didTapAddButton: Bool = false
    @Published var isTitleEmpty = false
    // MARK: - API Request를 위한 Property Wrapper
    @Published var title = ""
    @Published var memo = ""
    @Published var amount = 20000
    @Published var createAt = ""
    @Published var star = 5
    @Published var type = ""
    @Published var binaryFileList: [APIParameters.InsertEconomicActivityReqDto.BinaryFileList] = []
    
    @Published var data: InsertResDto?
    // MARK: - Porperties
    private var cancellable: Set<AnyCancellable> = []
    lazy var isVaild: AnyPublisher<Bool, Never> = $title
            .map { $0.count <= 16 } // 16자리 이하
            .eraseToAnyPublisher()
    
    func requestPHPhotoLibraryAuthorization(completion: @escaping () -> Void) {
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { authorizationStatus in
                switch authorizationStatus {
                case .limited:
                    completion()
                    print("limited authorization granted")
                case .authorized:
                    completion()
                    print("authorization granted")
                default:
                    print("Unimplemented")
                }
            }
        }
    }
    
    func insertDetailActivity() {
        guard Constants.getKeychainValue(forKey: Constants.KeychainKey.token) != nil else { return }
        
        APIClient.dispatch(
            APIRouter.InsertReqDto(
                headers: APIHeader.Default(token: TempToken.token),
                body: APIParameters.InsertEconomicActivityReqDto(
                    binaryFileList: [],
                    amount: amount,
                    type: type,
                    title: title,
                    memo: memo,
                    createAt: createAt,
                    star: star)))
        .sink { data in
            switch data {
            case .failure(let error):
                break
            case .finished:
                break
            }
        } receiveValue: { response in
            self.data = response
            print(self.data)
        }.store(in: &cancellable)
    }
    
}

