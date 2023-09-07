//
//  WeekCollectionHeaderView.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/09/06.
//

import UIKit
import SnapKit
import Then

final class WeekCollectionHeaderView: UICollectionReusableView {
    // MARK: - UI Components
    private lazy var label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Style & Layout
extension WeekCollectionHeaderView {
    private func setup() {
        setAttribute()
        setLayout()
    }
    
    private func setAttribute() {
        addSubviews(label)
        
        label = label.then {
            $0.text = "활성화된 요일"
            $0.font = R.Font.body0
            $0.textColor = R.Color.white
        }
    }
    
    private func setLayout() {
        label.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
