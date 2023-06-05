//
//  DataExportViewController.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/04/04.
//

import UIKit
import Then
import SnapKit

final class DataExportViewController: BaseViewController {
	// MARK: - Properties
    // MARK: - UI components
    private lazy var mainLabel = UILabel()
    private lazy var subLabel = UILabel()
    private lazy var exportButton = UIButton()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setup()		// 초기 셋업할 코드들
	}
}
// MARK: - Action
private extension DataExportViewController {
    @objc func presentShareSheet() {
        // 데이터를 넘겨야함 -> sample data
        // 실제 데이터를 넘길경우 비동기 처리를 해줘야함
        let vc = UIActivityViewController(activityItems: ["데이터 넘겨주자!"], applicationActivities: nil)
        present(vc, animated: true)
    }
}
// MARK: - Style & Layouts
private extension DataExportViewController {
	// 초기 셋업할 코드들
    private func setup() {
        setAttribute()
        setLayout()
    }
    
    private func setAttribute() {
		// [view]
		view.backgroundColor = R.Color.gray100
        navigationItem.title = "데이터 내보내기"
        
		mainLabel = mainLabel.then {
			$0.text = "데이터를 엑셀 파일로 내보내어 자유롭게 사용할 수 있어요."
			$0.font = R.Font.h2
			$0.textColor = R.Color.gray900
			$0.numberOfLines = 2
		}
		
		subLabel = subLabel.then {
			let attrString = NSMutableAttributedString(string: "기록한 경제활동 내역의 제목, 수입/지출, 상세 정보를 엑셀 파일로 첨부하여 메일로 전송합니다.")
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.lineSpacing = 2
			attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
			$0.attributedText = attrString
			$0.font = R.Font.body1
			$0.textColor = R.Color.gray800
			$0.numberOfLines = 2
		}
		
		exportButton = exportButton.then {
			$0.setTitle("데이터 내보내기", for: .normal)
			$0.titleLabel?.font = R.Font.title1
			$0.backgroundColor = R.Color.gray900
			$0.setButtonLayer()
			$0.addTarget(self, action: #selector(presentShareSheet), for: .touchUpInside)
		}
    }
    
    private func setLayout() {
		view.addSubviews(mainLabel, subLabel, exportButton)

        mainLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(32)
            $0.left.right.equalToSuperview().inset(24)
        }
            
        subLabel.snp.makeConstraints {
            $0.top.equalTo(mainLabel.snp.bottom).offset(32)
            $0.left.right.equalToSuperview().inset(24)
        }
        
        exportButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().inset(58)
            $0.height.equalTo(56)
        }
    }
}
