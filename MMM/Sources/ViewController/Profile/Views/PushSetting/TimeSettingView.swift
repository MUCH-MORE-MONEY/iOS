//
//  TimeSettingView.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/08/24.
//

import UIKit
import Then
import SnapKit

final class TimeSettingView: UIView {
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
extension TimeSettingView {
    func configure(_ isOn: Bool) {
        if isOn {
            DispatchQueue.main.async {
                self.backgroundColor = R.Color.gray900
                self.imageView.isHidden = false
                self.mainLabel.text = "매일 09:00 PM"
            }

        } else {
            DispatchQueue.main.async {
                self.backgroundColor = R.Color.gray300
                self.imageView.isHidden = true
                self.mainLabel.text = "매일 09:00 PM"
            }
        }
    }
}

// MARK: - Style & Layout
extension TimeSettingView {
    private func setup() {
        setAttribute()
        setLayout()
    }
    
    private func setAttribute() {
        backgroundColor = R.Color.gray900
        
        addSubviews(mainLabel, imageView)
        
        mainLabel = mainLabel.then {
            $0.text = "매일 09:00 PM"
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
