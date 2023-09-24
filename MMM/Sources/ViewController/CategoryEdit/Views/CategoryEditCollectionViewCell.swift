//
//  CategoryEditCollectionViewCell.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/24.
//

import UIKit
import Then
import SnapKit
import ReactorKit

// 상속하지 않으려면 final 꼭 붙이기
final class CategoryEditCollectionViewCell: BaseCollectionViewCell, View {
	typealias Reactor = CategoryEditCollectionViewCellReactor
	
	// MARK: - Constants
	private enum UI {
		static let priceLabelMargin: UIEdgeInsets = .init(top: 8, left: 0, bottom: 0, right: 0)
	}
	
	// MARK: - UI Components
	private lazy var titleLabel = UILabel()
	private lazy var editButton = UIButton()
	private lazy var dragButton = UIButton()

	override func layoutSubviews() {
		super.layoutSubviews()
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		titleLabel.text = ""
	}
	
	func bind(reactor: CategoryEditCollectionViewCellReactor) {
		bindState(reactor)
		bindAction(reactor)
	}
}
//MARK: - Bind
extension CategoryEditCollectionViewCell {
	// MARK: 데이터 변경 요청 및 버튼 클릭시 요청 로직(View -> Reactor)
	private func bindAction(_ reactor: CategoryEditCollectionViewCellReactor) {
		titleLabel.text = reactor.currentState.category.title
	}
	
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: CategoryEditCollectionViewCellReactor) {
	}
}
//MARK: - Action
extension CategoryEditCollectionViewCell {
}
//MARK: - Attribute & Hierarchy & Layouts
extension CategoryEditCollectionViewCell {
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()
		
		titleLabel = titleLabel.then {
			$0.font = R.Font.body1
			$0.textColor = R.Color.gray100
			$0.textAlignment = .left
		}
		
		editButton = editButton.then {
			$0.setImage(R.Icon.iconEditGray24, for: .normal)
			$0.imageView?.contentMode = .scaleAspectFit
		}
		
		dragButton = dragButton.then {
			$0.setImage(R.Icon.drag, for: .normal)
			$0.imageView?.contentMode = .scaleAspectFit
		}
	}
	
	override func setHierarchy() {
		super.setHierarchy()
		
		contentView.addSubviews(titleLabel, editButton, dragButton)
	}
	
	override func setLayout() {
		super.setLayout()
		
		titleLabel.snp.makeConstraints {
			$0.top.leading.equalToSuperview()
			$0.trailing.lessThanOrEqualTo(editButton.snp.leading).offset(4)
		}
		
		dragButton.snp.makeConstraints {
			$0.centerY.equalTo(titleLabel)
			$0.trailing.equalToSuperview()
		}
		
		editButton.snp.makeConstraints {
			$0.centerY.equalTo(titleLabel)
			$0.trailing.equalTo(dragButton).offset(8)
		}
	}
}
