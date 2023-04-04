//
//  DataExportViewController.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/04/04.
//

import UIKit
import Then
import SnapKit

class DataExportViewController: UIViewController {

    // MARK: - UI components
    private lazy var mainLabel = UILabel().then {
        $0.text = "데이터를 엑셀 파일로 내보내어 자유롭게 사용할 수 있어요."
        $0.font = R.Font.h2
        $0.textColor = R.Color.gray900
        $0.numberOfLines = 2
    }
    
    private lazy var subLabel = UILabel().then {
        $0.text = "기록한 경제활동 내역의 제목, 수입/지출, 상세 정보를 엑셀 파일로 첨부하여 메일로 전송합니다."
        $0.font = R.Font.body1
        $0.textColor = R.Color.gray800
        $0.numberOfLines = 2

    }
    
    private lazy var exportButton = UIButton().then {
        $0.setTitle("데이터 내보내기", for: .normal)
        $0.titleLabel?.font = R.Font.title1
        $0.backgroundColor = R.Color.gray900
        $0.layer.cornerRadius = 4
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.25
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.shadowRadius = 8
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view.
    }
}

// MARK: - Style & Layouts
private extension DataExportViewController {
    private func setup() {
        setAttribute()
        setLayout()
    }
    
    private func setAttribute() {
        navigationItem.title = "데이터 내보내기"
        
        view.addSubviews(mainLabel, subLabel, exportButton)
    }
    
    private func setLayout() {
        mainLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(32)
            $0.left.right.equalToSuperview().inset(24)
        }
            
        subLabel.snp.makeConstraints {
            $0.top.equalTo(mainLabel.snp.bottom).offset(24)
            $0.left.right.equalToSuperview().inset(24)
        }
        
        exportButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().inset(58)
            $0.height.equalTo(56)
        }
    }
}