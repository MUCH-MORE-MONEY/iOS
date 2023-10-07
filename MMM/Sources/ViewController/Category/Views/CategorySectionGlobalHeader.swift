//
//  CategorySectionGlobalHeader.swift
//  MMM
//
//  Created by geonhyeong on 10/7/23.
//

import UIKit
import Then
import SnapKit
import ReactorKit

// 상속하지 않으려면 final 꼭 붙이기
final class CategorySectionGlobalHeader: BaseCollectionReusableView, View {
	typealias Reactor = CategoryMainReactor
	// MARK: - Constants
	
	// MARK: - UI Components
	private lazy var upperLabel = UILabel()
	private lazy var lowwerLabel = UILabel()

	override init(frame: CGRect) {
		super.init(frame: frame)
	}

	override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
		self.frame = layoutAttributes.frame
	}
	
	func bind(reactor: CategoryMainReactor) {
		bindState(reactor)
		bindAction(reactor)
	}
}
//MARK: - Bind
extension CategorySectionGlobalHeader {
	// MARK: 데이터 변경 요청 및 버튼 클릭시 요청 로직(View -> Reactor)
	private func bindAction(_ reactor: CategoryMainReactor) { }
	
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: CategoryMainReactor) { }
}
//MARK: - Action
extension CategorySectionGlobalHeader {
}
//MARK: - Attribute & Hierarchy & Layouts
extension CategorySectionGlobalHeader {
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()
		
		backgroundColor = R.Color.gray900
		
		upperLabel = upperLabel.then {
			$0.text = "카테고리 유형"
			$0.font = R.Font.prtendard(family: .medium, size: 14)
			$0.textColor = R.Color.gray600
			$0.textAlignment = .left
		}
		
		lowwerLabel = lowwerLabel.then {
			$0.text = "카테고리"
			$0.font = R.Font.prtendard(family: .medium, size: 14)
			$0.textColor = R.Color.gray600
			$0.textAlignment = .left
		}
	}
	
	override func setHierarchy() {
		super.setHierarchy()
		
		addSubviews(upperLabel, lowwerLabel)
	}
	
	override func setLayout() {
		super.setLayout()
		
		upperLabel.snp.makeConstraints {
			$0.leading.equalToSuperview()
			$0.top.equalToSuperview().inset(16)
		}
		
		lowwerLabel.snp.makeConstraints {
			// Category Content VC의 group의 leading과 값이 같아야함
			$0.leading.equalToSuperview().inset(192)
			$0.top.equalToSuperview().inset(16)
		}
	}
}
