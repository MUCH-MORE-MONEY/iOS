//
//  CategoryEditSectionHeader.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/24.
//

import UIKit
import Then
import SnapKit

// 상속하지 않으려면 final 꼭 붙이기
final class CategoryEditSectionHeader: BaseCollectionReusableView {
	// MARK: - Constants
	private enum UI {
		static let contentMargin: UIEdgeInsets = .init(top: 0, left: 24, bottom: 0, right: 24)
	}
	
	// MARK: - UI Components
	private lazy var titleLabel = UILabel()
	
	func bind(reactor: CategoryReactor) {
		bindState(reactor)
		bindAction(reactor)
	}
}
//MARK: - Bind
extension CategoryEditSectionHeader {
	// MARK: 데이터 변경 요청 및 버튼 클릭시 요청 로직(View -> Reactor)
	private func bindAction(_ reactor: CategoryReactor) {
	}
	
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: CategoryReactor) {
	}
}
//MARK: - Action
extension CategoryEditSectionHeader {
	// 외부에서 입력
	func setDate(title: String) {
		titleLabel.text = title
	}
}
//MARK: - Attribute & Hierarchy & Layouts
extension CategoryEditSectionHeader {
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()

		titleLabel = titleLabel.then {
			$0.font = R.Font.title3
			$0.textColor = R.Color.gray100
			$0.textAlignment = .left
		}
	}
	
	override func setHierarchy() {
		super.setHierarchy()
		
		addSubviews(titleLabel)
	}
	
	override func setLayout() {
		super.setLayout()
		
		titleLabel.snp.makeConstraints {
			$0.top.equalToSuperview().inset(15)
			$0.leading.trailing.equalToSuperview()
		}
	}
}
