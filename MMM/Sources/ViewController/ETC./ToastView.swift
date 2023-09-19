//
//  ToastView.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/06/28.
//

import UIKit
import SnapKit

class ToastView: UIView {
    // MARK: - UI Components
    private lazy var toastLabel = BasePaddingLabel(padding: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
    
    // MARK: - Properties
    private var toastMessage: String
    
    init(toastMessage: String) {
        self.toastMessage = toastMessage
        super.init(frame: .zero)
        setup()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ToastView {
    private func setup() {
        bind()
        setAttribute()
        setLayout()
    }
    
    private func bind() { }
    
    private func setAttribute() {
        addSubviews(toastLabel)
        
        toastLabel = toastLabel.then {
            $0.text = toastMessage
            $0.backgroundColor = R.Color.black.withAlphaComponent(0.8)
            $0.font = R.Font.body1
            $0.textColor = R.Color.white
            $0.alpha = 1.0
            $0.layer.cornerRadius = 8
            $0.clipsToBounds = true
        }
    }
    
    private func setLayout() {
        toastLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
}
