//
//  PushSettingDetailViewController.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/08/24.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class PushSettingDetailViewController: BaseViewController {
    // MARK: - UI Components
    private lazy var mainLabel = UILabel()
    private lazy var timeSettingView = DetailTimeSettingView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)

    }
}


extension PushSettingDetailViewController {
    private func setup() {
        setAttribute()
        setLayout()
    }
    
    private func setAttribute() {
        view.backgroundColor = R.Color.gray100
        title = "알람 시간 지정"
        view.addSubviews(mainLabel, timeSettingView)
        
        timeSettingView = timeSettingView.then {
            $0.layer.cornerRadius = 4
        }
        
        mainLabel = mainLabel.then {
            $0.text = "경제활동에 유용한 알림 받을 시간을 설정해주세요!"
            $0.font = R.Font.title1
            $0.textColor = R.Color.gray900
            $0.numberOfLines = 0
        }
    }
    
    private func setLayout() {
        mainLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
        }
        
        timeSettingView.snp.makeConstraints {
            $0.top.equalTo(mainLabel.snp.bottom).offset(16)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
        }
    }
}
