//
//  AddScheduleTapView.swift
//  MMM
//
//  Created by yuraMacBookPro on 2/16/24.
//

import UIKit

import UIKit
import SnapKit
import Then

final class AddScheduleTapView: BaseView {
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

// MARK: - Action
extension AddScheduleTapView {
    func setTitleAndColor(by text: String) {
        let split = text.components(separatedBy: ",")
        guard let type = split.first else { return }
        guard let period = split.last else { return }
        titleLabel.text = type == "반복 안함" ? "일정반복" : "\(type), \(period)"
        titleLabel.textColor = text == "반복 안함" ? R.Color.gray400 : R.Color.gray800
    }
    
    func setViewisHomeDetail() {
        arrowImageView.isHidden = true
    }
}

// MARK: - setup
extension AddScheduleTapView {
    override func setup() {
        setAttribute()
        setHierarchy()
        setLayout()
    }
    
    override func setAttribute() {
        titleLabel = titleLabel.then {
            $0.text = "일정반복"
            $0.font = R.Font.body1
            $0.textColor = R.Color.gray400
        }
        
        categoryImageView = categoryImageView.then {
            $0.image = R.Icon.iconRepeat24
            $0.contentMode = .scaleAspectFit
        }
        
        arrowImageView = arrowImageView.then {
            $0.image = R.Icon.iconArrowNextGray16
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
