//
//  CategoryEditSectionGlobalFooter.swift
//  MMM
//
//  Created by geonhyeong on 10/7/23.
//

import UIKit
import Then
import SnapKit
import ReactorKit

// 상속하지 않으려면 final 꼭 붙이기
final class CategoryEditSectionGlobalFooter: BaseCollectionReusableView, View {
	typealias Reactor = CategoryEditReactor
	// MARK: - Constants
	
	// MARK: - UI Components
	private lazy var editButton = UIButton()

	override init(frame: CGRect) {
		super.init(frame: frame)
	}

	override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
		self.frame = layoutAttributes.frame
	}
	
	func bind(reactor: CategoryEditReactor) {
		bindState(reactor)
		bindAction(reactor)
	}
}
//MARK: - Bind
extension CategoryEditSectionGlobalFooter {
	// MARK: 데이터 변경 요청 및 버튼 클릭시 요청 로직(View -> Reactor)
	private func bindAction(_ reactor: CategoryEditReactor) { 
		editButton.rx.tap
			.withUnretained(self)
			.map { .didTapUpperEditButton }
			.bind(to: reactor.action)
			.disposed(by: disposeBag)
	}
	
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: CategoryEditReactor) { }
}
//MARK: - Action
extension CategoryEditSectionGlobalFooter {
}
//MARK: - Attribute & Hierarchy & Layouts
extension CategoryEditSectionGlobalFooter {
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()
		
		backgroundColor = R.Color.gray900
		
		editButton = editButton.then {
			$0.setTitle("카테고리 유형 편집하기", for: .normal)
			$0.titleLabel?.font = R.Font.prtendard(family: .medium, size: 18)
			$0.backgroundColor = R.Color.black
			$0.layer.cornerRadius = 4
			$0.layer.shadowColor = UIColor.black.cgColor
			$0.layer.shadowOpacity = 0.25
			$0.layer.shadowOffset = CGSize(width: 0, height: 2)
			$0.layer.shadowRadius = 8
		}
	}
	
	override func setHierarchy() {
		super.setHierarchy()
		
		addSubviews(editButton)
	}
	
	override func setLayout() {
		super.setLayout()
		
		editButton.snp.makeConstraints {
			$0.leading.trailing.equalToSuperview()
			$0.height.equalTo(56)
		}
	}
}
