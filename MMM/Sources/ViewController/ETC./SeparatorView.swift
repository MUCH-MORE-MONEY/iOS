//
//  SeparatorView.swift
//  MMM
//
//  Created by Park Jungwoo on 10/15/23.
//

import UIKit
import SnapKit
import Then

final class SeparatorView: BaseView {
    // MARK: - UI Components
    private lazy var view = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    
}

extension SeparatorView {
    override func setup() {
        setAttribute()
        setHierarchy()
        setLayout()
    }
    
    override func setAttribute() {
        view = view.then {
            $0.backgroundColor = R.Color.gray200
        }
    }
    
    override func setHierarchy() {
        addSubviews(view)
    }
    
    override func setLayout() {
        view.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
}
