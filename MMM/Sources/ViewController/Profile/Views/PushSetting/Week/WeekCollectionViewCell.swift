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
    private lazy var button = UIButton()
    
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
        button.setTitle(text, for: .normal)
    }
}

// MARK: - Style & Layout
extension WeekCollectionViewCell {
    private func setup() {
        bind()
        setAttribute()
        setLayout()
    }
    
    private func bind() {
        
    }
    
    private func setAttribute() {
        addSubviews(button)
        
        button = button.then {
            $0.setTitle("일", for: .normal)
            $0.setTitleColor(R.Color.white, for: .normal)
            $0.setBackgroundColor(R.Color.orange500, for: .normal)
        }
    }
    
    private func setLayout() {
        button.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
