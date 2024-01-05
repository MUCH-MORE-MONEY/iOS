//
//  CategorySectionHeader.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/16.
//

import UIKit
import Then
import SnapKit

// 상속하지 않으려면 final 꼭 붙이기
final class CategorySectionHeader: BaseCollectionReusableView {
	// MARK: - Constants
	private enum UI {
		static let priceLabelMargin: UIEdgeInsets = .init(top: 8, left: 8, bottom: 0, right: 8)
		static let contentMargin: UIEdgeInsets = .init(top: 12, left: 8, bottom: 0, right: 30)
	}
	
	// MARK: - UI Components
	private lazy var titleLabel = UILabel()
	private lazy var priceLabel = UILabel()
	private lazy var radioButton = UIButton()
	
	func bind(reactor: CategoryMainReactor) {
		bindState(reactor)
		bindAction(reactor)
	}
}
//MARK: - Bind
extension CategorySectionHeader {
	// MARK: 데이터 변경 요청 및 버튼 클릭시 요청 로직(View -> Reactor)
	private func bindAction(_ reactor: CategoryMainReactor) {
	}
	
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: CategoryMainReactor) {
	}
}
//MARK: - Action
extension CategorySectionHeader {
	// 외부에서 입력
	func setDate(category: Category, type: String) {
		titleLabel.text = category.title
		priceLabel.text = category.dateYM.suffix(2) + "월 | " + category.total.withCommas() + " 원"
		
		// 비율 반올림
		let roundValue = Int(round(category.ratio))
		radioButton.setTitle("\(roundValue)%", for: .normal)
		
		// 0%에 대한 Case 처리
		if roundValue == 0 {
			radioButton.backgroundColor = type == "01" ? R.Color.orange800 : R.Color.blue800
		} else {
			radioButton.backgroundColor = type == "01" ? R.Color.orange600 : R.Color.blue600
		}
		
		// 버튼 크기 변경
		radioButton.snp.updateConstraints {
			$0.width.equalTo(roundValue == 100 ? 50 : 43)
		}
	}
}
//MARK: - Attribute & Hierarchy & Layouts
extension CategorySectionHeader {
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()
		
		radioButton = radioButton.then {
			$0.setTitleColor(R.Color.white, for: .normal)
			$0.titleLabel?.font = R.Font.title3
			$0.layer.cornerRadius = 3
			$0.isEnabled = true
		}
		
		titleLabel = titleLabel.then {
			$0.font = R.Font.title3
			$0.textColor = R.Color.gray100
			$0.textAlignment = .left
		}
		
		priceLabel = priceLabel.then {
			$0.font = R.Font.body3
			$0.textColor = R.Color.gray500
			$0.textAlignment = .left
		}
	}
	
	override func setHierarchy() {
		super.setHierarchy()
		
		addSubviews(radioButton, titleLabel, priceLabel)
	}
	
	override func setLayout() {
		super.setLayout()
		
		radioButton.snp.makeConstraints {
			$0.top.equalToSuperview().inset(UI.contentMargin.top)
			$0.leading.equalToSuperview()
			$0.width.equalTo(43)
			$0.height.equalTo(24)
		}
		
		titleLabel.snp.makeConstraints {
			$0.centerY.equalTo(radioButton)
			$0.leading.equalTo(radioButton.snp.trailing).offset(UI.priceLabelMargin.left)
			$0.trailing.equalToSuperview()
		}
		
		priceLabel.snp.makeConstraints {
			$0.top.equalTo(titleLabel.snp.bottom).offset(UI.priceLabelMargin.top)
			$0.leading.equalTo(radioButton.snp.trailing).offset(UI.priceLabelMargin.left)
			$0.trailing.equalToSuperview()
		}
	}
}
