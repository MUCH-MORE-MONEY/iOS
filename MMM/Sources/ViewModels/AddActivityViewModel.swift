//
//  AddActivityViewModel.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/05/23.
//

import UIKit
import Photos

final class AddActivityViewModel {
    @Published var didTapAddButton: Bool = false
    @Published var titleText = ""
    @Published var memoText = ""
    
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

