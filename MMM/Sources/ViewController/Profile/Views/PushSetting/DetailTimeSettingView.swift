//
//  TimeSettingView.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/08/24.
//

import UIKit
import Then
import SnapKit

final class DetailTimeSettingView: UIView {
    
    // MARK: - UI Components
    private lazy var textLabel = UILabel()
    private lazy var timeLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

// MARK: - Actions
extension DetailTimeSettingView {
    func configure(_ dateTitle: String) {
        timeLabel.text = dateTitle
    }
}

extension DetailTimeSettingView {
    private func setup() {
        setAttribute()
        setLayout()
    }
    
    private func setAttribute() {
        backgroundColor = R.Color.gray900
        
        addSubviews(textLabel, timeLabel)
        
        textLabel = textLabel.then {
            $0.text = "시간"
            $0.font = R.Font.body0
            $0.textColor = R.Color.white
        }
        
        timeLabel = timeLabel.then {
            $0.text = Common.getCustomPushTime()
            $0.font = R.Font.body0
            $0.textColor = R.Color.white
        }
    }
    
    private func setLayout() {
        textLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.left.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().offset(-16)
        }
        
        timeLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
}
