//
//  AddDetailViewController.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/05/31.
//

import UIKit
import Combine
import SnapKit
import Then

class AddDetailViewController: BaseAddActivityViewController {
    // MARK: - UI Components
    
    // MARK: - Properties
    private var viewModel: EditActivityViewModel

    private var cancellable = Set<AnyCancellable>()
    
    init(viewModel: EditActivityViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

// MARK: - Style & Layout & Bind
extension AddDetailViewController {
    private func setup() {
        setAttribute()
        setLayout()
        bind()
    }
    
    private func setAttribute() {
        title = viewModel.date?.getFormattedDate(format: "MM월 dd일 경제활동")
    }
    
    private func setLayout() {
        remakeConstraintsByCameraImageView()
    }
    
    // MARK: - bind
    private func bind() {
        
    }
}
