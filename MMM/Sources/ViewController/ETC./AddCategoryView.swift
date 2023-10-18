//
//  AddCategoryView.swift
//  MMM
//
//  Created by Park Jungwoo on 10/15/23.
//

import UIKit
import SnapKit
import Then

final class AddCategoryView: BaseView {
    // MARK: - UI Components
    private lazy var titleLabel = UILabel()
    private lazy var categoryImageView = UIImageView()
    private lazy var arrowImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - setup
extension AddCategoryView {
    override func setup() {
        setAttribute()
        setHierarchy()
        setLayout()
    }
    
    override func setAttribute() {
        titleLabel = titleLabel.then {
            $0.text = "카테고리"
            $0.font = R.Font.body1
            $0.textColor = R.Color.gray400
        }
        
        categoryImageView = categoryImageView.then {
            $0.image = R.Icon.iconCategory24
            $0.contentMode = .scaleAspectFit
        }
        
        arrowImageView = arrowImageView.then {
            $0.image = R.Icon.iconArrowNextGray24
            $0.contentMode = .scaleAspectFit
        }
    }
    
    override func setHierarchy() {
        addSubviews(titleLabel, categoryImageView, arrowImageView)
    }
    
    override func setLayout() {
        categoryImageView.snp.makeConstraints {
            $0.top.left.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(categoryImageView.snp.centerY)
            $0.left.equalTo(categoryImageView.snp.right).offset(12)
        }
        
        arrowImageView.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel.snp.centerY)
            $0.right.equalToSuperview()
        }
    }
}
