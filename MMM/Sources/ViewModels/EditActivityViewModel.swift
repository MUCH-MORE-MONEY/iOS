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
    @Published var titleText = ""
    @Published var memoText = ""
    @Published var isTitleEmpty = false
    
    lazy var isVaild: AnyPublisher<Bool, Never> = $titleText
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
    
    
}

