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
        let label = UILabel()
    
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
        
    }
    
    private func setLayout() {
        
    }
}
