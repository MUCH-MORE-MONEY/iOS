//
//  CategoryEditSectionFooter.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/24.
//

import UIKit
import Then
import SnapKit
import ReactorKit

// 상속하지 않으려면 final 꼭 붙이기
final class CategoryEditSectionFooter: BaseCollectionReusableView, View {
	// MARK: - Constants
	
	// MARK: - UI Components
	private var categoryAddButton = UIButton()
	private var separatorView = UIView()

	override init(frame: CGRect) {
		super.init(frame: frame)
	}

	override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
		self.frame = layoutAttributes.frame
	}
	
	func bind(reactor: CategoryReactor) {
		bindState(reactor)
		bindAction(reactor)
	}
}
//MARK: - Action
extension CategoryEditSectionFooter {
	// MARK: 데이터 변경 요청 및 버튼 클릭시 요청 로직(View -> Reactor)
	private func bindAction(_ reactor: CategoryReactor) {
		
//		categoryAddButton.rx.tap
//			.withUnretained(self)
//			.map { .didTapEditButton }
//			.bind(to: reactor.action)
//			.disposed(by: disposeBag)
	}
	
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: CategoryReactor) {
	}
}
//MARK: - Bind
extension CategoryEditSectionFooter {
	func setData(isLast: Bool = false) {
		self.separatorView.isHidden = isLast
	}
}
//MARK: - Action
extension CategoryEditSectionFooter {
}
//MARK: - Attribute & Hierarchy & Layouts
extension CategoryEditSectionFooter {
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()
		
		categoryAddButton = categoryAddButton.then {
			$0.setTitle("+ 카테고리 추가하기", for: .normal)
			$0.setTitleColor(R.Color.gray500, for: .normal)
			$0.setTitleColor(R.Color.gray500.withAlphaComponent(0.7), for: .highlighted)
			$0.setBackgroundColor(R.Color.gray800, for: .highlighted)
			$0.titleLabel?.font = R.Font.body1
			$0.contentHorizontalAlignment = .center
		}
		
		separatorView = separatorView.then {
			$0.backgroundColor = R.Color.gray800
		}
	}
	
	override func setHierarchy() {
		super.setHierarchy()
		
		addSubviews(categoryAddButton, separatorView)
	}
	
	override func setLayout() {
		super.setLayout()
		
		categoryAddButton.snp.makeConstraints {
			$0.leading.trailing.equalToSuperview()
			$0.height.equalTo(44)
		}
		
		separatorView.snp.makeConstraints {
			$0.top.equalTo(categoryAddButton.snp.bottom).offset(16)
			$0.horizontalEdges.bottom.equalToSuperview()
			$0.height.equalTo(1)
		}
	}
}
