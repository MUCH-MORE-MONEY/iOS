//
//  TextSettingView.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/08/24.
//

import UIKit
import Then
import SnapKit

final class CustomPushTextSettingView: UIView {
    // MARK: - UI Components
    private lazy var mainLabel = UILabel()
    private lazy var imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

// MARK: - Actions
extension CustomPushTextSettingView {
    func configure(_ isOn: Bool) {
        if isOn {
            backgroundColor = R.Color.gray900
            DispatchQueue.main.async {
                self.imageView.isHidden = false
            }
        } else {
            DispatchQueue.main.async {
                self.imageView.isHidden = true
            }
            backgroundColor = R.Color.gray300
        }
    }
    
    func setTitle(_ text: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.mainLabel.text = text
        }
    }
}
//MARK: - Attribute & Hierarchy & Layouts
extension CustomPushTextSettingView {
    private func setup() {
        setAttribute()
        setLayout()
    }
    
    private func setAttribute() {
        backgroundColor = R.Color.gray900
        
        addSubviews(mainLabel, imageView)
        
        mainLabel = mainLabel.then {
            $0.text = Common.getCustomPushText()
            $0.font = R.Font.body1
            $0.textColor = R.Color.white
        }
        
        imageView = imageView.then {
            $0.image = R.Icon.arrowNextWhite16
        }
    }
    
    private func setLayout() {
        mainLabel.snp.makeConstraints {
            $0.top.left.equalToSuperview().offset(8)
            $0.bottom.equalToSuperview().offset(-8)
        }
        
        imageView.snp.makeConstraints {
            $0.centerY.equalTo(mainLabel.snp.centerY)
            $0.right.equalToSuperview().offset(-8)
        }
    }
}
