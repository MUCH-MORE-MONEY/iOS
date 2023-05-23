//
//  EditActivityViewController.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/05/22.
//

import UIKit
import Combine
import Then
import SnapKit

class EditActivityViewController: BaseAddActivityViewController {
    var viewModel = HomeDetailViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

extension EditActivityViewController {
    // MARK: - Style & Layout
    private func setup() {
        setAttribute()
        setLayout()
        bind()
    }
    
    func setVM(_ viewModel: HomeDetailViewModel) {
        self.viewModel = viewModel
    }
    
    private func setAttribute() {
        memoTextView.text = viewModel.detailActivity?.memo
        titleTextFeild.text = viewModel.detailActivity?.title
        totalPrice.text = viewModel.detailActivity?.amount
        for i in 0..<(viewModel.detailActivity?.star ?? 0) {
            starList[i].image = R.Icon.iconStarBlack24
        }
    }
    
    private func setLayout() {

        
    }
    
    private func bind() {
        
    }
}
