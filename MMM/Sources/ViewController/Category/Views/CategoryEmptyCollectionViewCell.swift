//
//  CategoryEmptyCollectionViewCell.swift
//  MMM
//
//  Created by geonhyeong on 10/25/23.
//

import UIKit
import Then
import SnapKit
import ReactorKit

// 상속하지 않으려면 final 꼭 붙이기
final class CategoryEmptyCollectionViewCell: BaseCollectionViewCell, View {
	typealias Reactor = CategoryCollectionViewCellReactor
	
	// MARK: - Constants
	private enum UI { }
	
	// MARK: - UI Components
	private lazy var titleLabel = UILabel()
	
	override func layoutSubviews() {
		super.layoutSubviews()
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		titleLabel.text = ""
	}
	
	func bind(reactor: CategoryCollectionViewCellReactor) {
		bindState(reactor)
		bindAction(reactor)
	}
}
//MARK: - Bind
extension CategoryEmptyCollectionViewCell {
	// MARK: 데이터 변경 요청 및 버튼 클릭시 요청 로직(View -> Reactor)
	private func bindAction(_ reactor: CategoryCollectionViewCellReactor) { }
	
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: CategoryCollectionViewCellReactor) { }
}
//MARK: - Action
extension CategoryEmptyCollectionViewCell {
	// 외부에서 입력
	func setData() { titleLabel.text = "카테고리가 없어요" }
}
//MARK: - Attribute & Hierarchy & Layouts
extension CategoryEmptyCollectionViewCell {
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()
		
		titleLabel = titleLabel.then {
			$0.font = R.Font.body1
			$0.textColor = R.Color.gray800
			$0.textAlignment = .left
		}
	}
	
	override func setHierarchy() {
		super.setHierarchy()
		
		contentView.addSubviews(titleLabel)
	}
	
	override func setLayout() {
		super.setLayout()
		
		titleLabel.snp.makeConstraints {
			$0.centerY.leading.equalToSuperview()
			$0.trailing.equalToSuperview().offset(24)
		}
	}
}
