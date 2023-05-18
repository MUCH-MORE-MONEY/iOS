//
//  HomeFilterViewController.swift
//  MMM
//
//  Created by geonhyeong on 2023/05/18.
//

import UIKit
import Combine
import Then
import SnapKit

final class HomeFilterViewController: BaseViewController {
	// MARK: - Properties
	// MARK: - UI Components
	private lazy var highlightLabel = UILabel()
	private lazy var highlightDescriptionLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
		setup()		// 초기 셋업할 코드들
    }
}

//MARK: - Style & Layouts
private extension HomeFilterViewController {
	// 초기 셋업할 코드들
	private func setup() {
		bind()
		setAttribute()
		setLayout()
	}
	
	private func bind() {
	}
	
	private func setAttribute() {
		// [view]
		view.backgroundColor = R.Color.gray100
		title = "달력 관리"
		
		highlightLabel = highlightLabel.then {
			$0.text = "금액 하이라이트 설정"
			$0.font = R.Font.h5
			$0.textColor = R.Color.gray800
		}
		
		highlightDescriptionLabel = highlightDescriptionLabel.then {
			let attrString = NSMutableAttributedString(string: "하루 중 일정 경제활동을 했을 때 달력에 원하는 색깔로 강조해줘요.")
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.lineSpacing = 2
			paragraphStyle.lineBreakMode = .byCharWrapping
			attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
			$0.attributedText = attrString
			$0.font = R.Font.body3
			$0.textColor = R.Color.gray800
			$0.numberOfLines = 0
		}
	}
	
	private func setLayout() {
		view.addSubviews(highlightLabel, highlightDescriptionLabel)
		
		highlightLabel.snp.makeConstraints {
			$0.top.leading.trailing.equalToSuperview().inset(24)
		}
		
		highlightDescriptionLabel.snp.makeConstraints {
			$0.leading.trailing.equalToSuperview().inset(24)
			$0.top.equalTo(highlightLabel.snp.bottom).offset(13)
		}
	}
}
