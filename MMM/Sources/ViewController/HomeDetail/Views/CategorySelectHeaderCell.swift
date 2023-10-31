//
//  CategorySelectHeaderCellCollectionReusableView.swift
//  MMM
//
//  Created by Park Jungwoo on 10/31/23.
//

import UIKit
import Then
import SnapKit

final class CategorySelectHeaderCell: BaseCollectionReusableView {
    lazy var label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

extension CategorySelectHeaderCell {
    func setData(_ title: String) {
        label.text = title
    }
}

extension CategorySelectHeaderCell {
    override func setAttribute() {
        super.setAttribute()
        label = label.then {
            $0.text = "라벨이다"
            $0.font = R.Font.title3
            $0.textColor = R.Color.black
        }
    }
    
    override func setHierarchy() {
        super.setHierarchy()
        
        addSubviews(label)
    }
    
    override func setLayout() {
        super.setLayout()
        
        label.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
