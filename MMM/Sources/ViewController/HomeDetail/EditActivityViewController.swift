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
    // MARK: - UI Components
    private lazy var editIconImage = UIImageView()
    
    // MARK: - Properties
    var viewModel: HomeDetailViewModel
    var date: Date
    var navigationTitle: String {
        return date.getFormattedDate(format: "yyyy.MM.dd")
    }
    
    
    init(viewModel: HomeDetailViewModel, date: Date) {
        self.viewModel = viewModel
        self.date = date
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
        title = navigationTitle
        view.addSubviews(editIconImage)
        
        editIconImage = editIconImage.then {
            $0.image = R.Icon.iconEditGray24
            $0.contentMode = .scaleAspectFit
        }
        
        memoTextView.text = viewModel.detailActivity?.memo
        titleTextFeild.text = viewModel.detailActivity?.title
        totalPrice.text = viewModel.detailActivity?.amount
        for i in 0..<(viewModel.detailActivity?.star ?? 0) {
            starList[i].image = R.Icon.iconStarBlack24
        }
        
        if let amount = Int(viewModel.detailActivity?.amount ?? "0") {
            self.totalPrice.text = "\(amount.withCommas())원"
        }
        if let image = viewModel.mainImage {
            mainImageView.image = image
        }
        hasImage = viewModel.hasImage
        print("hasImage \(hasImage)")

        if hasImage {
            remakeConstraintsByMainImageView()
        } else {
            remakeConstraintsByCameraImageView()
        }
        print("editView : \(mainImageView.frame.height)")
    }
    
    private func setLayout() {
        editIconImage.snp.makeConstraints {
            $0.left.equalTo(activityType.snp.right).offset(15)
            $0.centerY.equalTo(activityType)
        }
        
    }
    
    private func bind() {
        
    }
}
