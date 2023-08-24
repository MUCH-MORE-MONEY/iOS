//
//  TextSettingView.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/08/24.
//

import UIKit
import Then
import SnapKit

final class TextSettingView: UIView {
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


extension TextSettingView {
    private func setup() {
        setAttribute()
        setLayout()
    }
    
    private func setAttribute() {
        backgroundColor = R.Color.gray900
        
        addSubviews(mainLabel, imageView)
        
        mainLabel = mainLabel.then {
            $0.text = "오늘의 경제활동을 작성해보세요"
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
