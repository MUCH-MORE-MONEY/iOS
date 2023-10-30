//
//  CategorySelectCell.swift
//  MMM
//
//  Created by Park Jungwoo on 10/31/23.
//

import UIKit
import Then
import SnapKit

final class CategorySelectCell: UICollectionViewCell {
    private lazy var label = UILabel()
    private lazy var imageView = UIImageView()
    private lazy var stackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CategorySelectCell {
    private func setup() {
        bind()
        setAttribute()
        setLayout()
    }
    
    private func bind() {
        
    }
    
    private func setAttribute() {
        addSubviews(stackView)
        stackView.addArrangedSubviews(label, imageView)
        
        stackView = stackView.then {
            $0.axis = .horizontal
            $0.spacing = 2
            $0.distribution = .fill
        }
        
        label = label.then {
            $0.text = "덕질 비용"
            $0.backgroundColor = R.Color.gray200
            $0.textColor = R.Color.white
        }
        
        imageView = imageView.then {
            $0.image = R.Icon.iconCheckWhite16
        }
    }
    
    private func setLayout() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
