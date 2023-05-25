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
    private lazy var titleStackView = UIStackView()
    private lazy var titleIcon = UIImageView()
    private lazy var titleText = UILabel()
    
    // MARK: - Properties
    private var detailViewModel: HomeDetailViewModel
    private var date: Date
    private var navigationTitle: String {
        return date.getFormattedDate(format: "yyyy.MM.dd")
    }
    
    
    init(viewModel: HomeDetailViewModel, date: Date) {
        self.detailViewModel = viewModel
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
        
    private func setAttribute() {
        setCustomTitle()
        view.addSubviews(editIconImage)
        
        editIconImage = editIconImage.then {
            $0.image = R.Icon.iconEditGray24
            $0.contentMode = .scaleAspectFit
        }
        

        
        setUIByViewModel()

    }
    
    private func setLayout() {
        editIconImage.snp.makeConstraints {
            $0.left.equalTo(activityType.snp.right).offset(15)
            $0.centerY.equalTo(activityType)
        }
    }
    
    private func bind() {
        addViewModel.titleText = detailViewModel.detailActivity?.title ?? ""
        addViewModel.memoText = detailViewModel.detailActivity?.memo ?? ""
    }
}

// MARK: - UI Funcitons
extension EditActivityViewController {
    private func setCustomTitle() {
        view.addSubview(titleStackView)
        titleStackView.addArrangedSubviews(titleText, titleIcon)
        titleStackView = titleStackView.then {
            $0.axis = .horizontal
            $0.spacing = 4
            $0.distribution = .fillProportionally
        }
        titleText = titleText.then {
            $0.text = navigationTitle
            $0.font = R.Font.title3
            $0.textColor = .white
        }
        
        titleIcon = titleIcon.then {
            $0.image = R.Icon.arrowExpandMore16
            $0.contentMode = .scaleAspectFit
        }
        
        navigationItem.titleView = titleStackView
    }
    
    private func setUIByViewModel() {

        satisfyingLabel.setSatisfyingLabelEdit(by: detailViewModel.detailActivity?.star ?? 0)

        memoTextView.text = detailViewModel.detailActivity?.memo
        titleTextFeild.text = detailViewModel.detailActivity?.title
        totalPrice.text = detailViewModel.detailActivity?.amount
        for i in 0..<(detailViewModel.detailActivity?.star ?? 0) {
            starList[i].image = R.Icon.iconStarBlack24
        }
        
        if let amount = Int(detailViewModel.detailActivity?.amount ?? "0") {
            self.totalPrice.text = "\(amount.withCommas())원"
        }
        if let image = detailViewModel.mainImage {
            mainImageView.image = image
        }
        hasImage = detailViewModel.hasImage
        print("hasImage \(hasImage)")

        if hasImage {
            remakeConstraintsByMainImageView()
        } else {
            remakeConstraintsByCameraImageView()
        }
        print("editView : \(mainImageView.frame.height)")
    }

}
