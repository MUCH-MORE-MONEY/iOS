//
//  CategorySelectHeaderCellCollectionReusableView.swift
//  MMM
//
//  Created by Park Jungwoo on 10/31/23.
//

import UIKit
import Then
import SnapKit

final class CategorySelectHeaderCell: UICollectionReusableView {
    lazy var label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

extension CategorySelectHeaderCell {
    private func setup() {
        bind()
        setAttribute()
        setLayout()
    }
    
    private func bind() {
        
    }
    
    private func setAttribute() {
        addSubviews(label)
        
        label = label.then {
            $0.text = "라벨이다"
            $0.font = R.Font.title3
            $0.textColor = R.Color.black
        }
    }
    
    private func setLayout() {
        label.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
