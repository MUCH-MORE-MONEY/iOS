//
//  OnboardingView.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/03/29.
//

import UIKit
import Then
import SnapKit

final class OnboardingView: UIView {
    
    private lazy var imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.layer.masksToBounds = true
        $0.image = R.Icon.onboarding1
    }
    
    private lazy var mainLabel1 = UILabel().then {
        $0.text = "내 하루를 돌아보며"
        $0.font = R.Font.h2
        $0.textColor = R.Color.gray800
        $0.textAlignment = .center
        $0.alpha = 0.0
    }
    
    private lazy var mainLabel2 = UILabel().then {
        $0.text = "가계부를 작성해요"
        $0.font = R.Font.h2
        $0.textColor = R.Color.orange500
        $0.textAlignment = .center
        $0.alpha = 0.0
    }
    
    private lazy var subLabel = UILabel().then {
        $0.text = "MMM과 함께 수입과 지출을 작성하며\n 그날의 하루를 돌아봐요"
        $0.font = R.Font.body1
        $0.textColor = R.Color.gray500
        $0.textAlignment = .center
        $0.numberOfLines = 2
        $0.alpha = 0.0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = R.Color.gray900
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setLayout() {
        addSubviews(imageView, mainLabel1, mainLabel2, subLabel)
        
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.right.equalToSuperview()
        }
        
        mainLabel1.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(32)
            $0.left.equalToSuperview().offset(100)
            $0.right.equalToSuperview().inset(98)
        }
        
        mainLabel2.snp.makeConstraints {
            $0.top.equalTo(mainLabel1.snp.bottom)
            $0.left.equalToSuperview().offset(100)
            $0.right.equalToSuperview().inset(98)
        }
        
        subLabel.snp.makeConstraints {
            $0.top.equalTo(mainLabel2.snp.bottom).offset(16)
            $0.left.equalToSuperview().offset(70)
            $0.right.equalToSuperview().inset(68)
        }
    }
}

extension OnboardingView {
    func setUp(image: UIImage, label1: String, label2: String, label3: String) {
        imageView.image = R.Icon.onboarding2
        mainLabel1.text = label1
        mainLabel2.text = label2
        subLabel.text = label3
    }
}
