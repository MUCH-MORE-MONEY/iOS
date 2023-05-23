//
//  EditActivityViewModel.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/05/22.
//

import UIKit
import Combine

final class EditActivityViewModel {
    // MARK: - Property Wrapper
    @Published var detailActivity: SelectDetailResDto?
    
    // MARK: - Porperties
    private var cancellable: Set<AnyCancellable> = []
}
