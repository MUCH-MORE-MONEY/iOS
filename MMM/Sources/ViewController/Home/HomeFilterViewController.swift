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
	}
	
	private func setLayout() {
		view.addSubviews(highlightLabel)
		
		highlightLabel.snp.makeConstraints {
			$0.top.leading.equalToSuperview().inset(24)
		}
	}
}
