//
//  CategorySheetCell.swift
//  MMM
//
//  Created by yuraMacBookPro on 1/23/24.
//

import UIKit
import Then
import SnapKit
import ReactorKit

final class CategorySheetCell: BaseCollectionViewCell, View {
    typealias Reactor = CategorySheetCollectionViewCellReactor
    
    private lazy var label = UILabel()
    private lazy var imageView = UIImageView()
    
    var backgroundType = true
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                contentView.backgroundColor = backgroundType ? R.Color.orange500 : R.Color.blue500
                imageView.image = R.Icon.iconCheckWhite16
                label.textColor = R.Color.white
                label.font = R.Font.body2
            } else {
                contentView.backgroundColor = R.Color.gray200
                imageView.image = R.Icon.iconCheckGray16
                label.textColor = R.Color.gray600
                label.font = R.Font.body3
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        var frame = layoutAttributes.frame
        frame.size.height = ceil(size.height)
        frame.size.width = ceil(size.width)
        layoutAttributes.frame = frame
        return layoutAttributes
    }
    
    func bind(reactor: CategorySheetCollectionViewCellReactor) {
        bindAction(reactor)
        bindState(reactor)
    }
}

//MARK: - Bind
extension CategorySheetCell {
    // MARK: 데이터 변경 요청 및 버튼 클릭시 요청 로직(View -> Reactor)
    private func bindAction(_ reactor: CategorySheetCollectionViewCellReactor) { }
    
    // MARK: 데이터 바인딩 처리 (Reactor -> View)
    private func bindState(_ reactor: CategorySheetCollectionViewCellReactor) { }
}


// MARK: - Actions
extension CategorySheetCell {
    func setData(_ title: String, _ isEarn: Bool) {
        self.label.text = title
        self.backgroundType = isEarn
    }
}

//MARK: - Attribute & Hierarchy & Layouts
extension CategorySheetCell {
    override func setHierarchy() {
        super.setHierarchy()
        contentView.addSubviews(label, imageView)
    }
    
    override func setAttribute() {
        super.setAttribute()
        
        contentView.layer.cornerRadius = 16
        contentView.backgroundColor = R.Color.gray200

        label = label.then {
            $0.text = "덕질 비용"
            $0.textColor = R.Color.gray600
            $0.font = R.Font.body3
        }
        
        imageView = imageView.then {
            $0.image = R.Icon.iconCheckGray16
            $0.contentMode = .scaleAspectFit
        }
    }
    
    override func setLayout() {
        super.setLayout()

        label.snp.makeConstraints {
            $0.left.equalToSuperview().offset(12)
            $0.centerY.equalToSuperview()
        }
        
        imageView.snp.makeConstraints {
            $0.left.equalTo(label.snp.right).offset(2)
            $0.centerY.equalToSuperview()
        }
    }
}
