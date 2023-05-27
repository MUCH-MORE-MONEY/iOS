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
    @Published var didTapAddButton: Bool = false
    @Published var isTitleEmpty = false
    // MARK: - API Request를 위한 Property Wrapper
    @Published var economicActivity: InsertEconomicActivity?
    @Published var title = ""
    @Published var memo = ""
    @Published var amount = 20000
    @Published var createAt = ""
    @Published var star = 5
    @Published var type = ""
    @Published var binaryFileList: [BinaryFileList] = []
    
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
        economicActivity = InsertEconomicActivity(binaryFileList: binaryFileList, amount: amount, type: type, title: title, memo: memo, createAt: createAt, star: star)
    }
    
}

