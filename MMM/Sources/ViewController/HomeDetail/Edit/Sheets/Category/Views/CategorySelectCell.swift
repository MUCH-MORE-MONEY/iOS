//
//  CategorySelectCell.swift
//  MMM
//
//  Created by Park Jungwoo on 10/31/23.
//

import UIKit
import Then
import SnapKit

final class CategorySelectCell: BaseCollectionViewCell {
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
}

extension CategorySelectCell {
    func setData(_ title: String, _ isEarn: Bool) {
        self.label.text = title
        self.backgroundType = isEarn
    }
}

extension CategorySelectCell {
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
