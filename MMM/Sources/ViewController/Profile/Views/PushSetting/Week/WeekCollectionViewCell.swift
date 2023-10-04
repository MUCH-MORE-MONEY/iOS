//
//  WeekCollectionViewCell.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/09/06.
//

import UIKit
import Then
import SnapKit

final class WeekCollectionViewCell: UICollectionViewCell {
    private lazy var label = UILabel()
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                label.backgroundColor = R.Color.orange500
            } else {
                label.backgroundColor = R.Color.gray600
                label.textColor = R.Color.gray400
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Actions
extension WeekCollectionViewCell {
    func configure(_ text: String) {
        label.text = text
    }
}
//MARK: - Attribute & Hierarchy & Layouts
extension WeekCollectionViewCell {
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
            $0.text = "일"
            $0.textAlignment = .center
            $0.textColor = R.Color.white
            $0.backgroundColor = R.Color.orange500
        }
    }
    
    private func setLayout() {
        label.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
