//
//  DefaultImageView.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/05/12.
//

import UIKit
import SnapKit
import Then

final class BaseCameraImageView: UIView {
    // MARK: - UI Components
    private lazy var view = UIView().then {
        $0.backgroundColor = R.Color.gray100
    }
    
    private lazy var cameraButton = UIButton().then {
        $0.setImage(R.Icon.camera48, for: .normal)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Style & Layout
extension BaseCameraImageView {
    private func setup() {
        setAttribute()
        setLayout()
    }
    
    private func setAttribute() {
        view.addSubviews(cameraButton)
    }
    
    private func setLayout() {
        view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        cameraButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
}
