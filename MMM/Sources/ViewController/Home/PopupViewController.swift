//
//  PopupViewController.swift
//  MMM
//
//  Created by geonhyeong on 4/9/24.
//

import UIKit
import Then
import SnapKit
import ReactorKit

final class PopupViewController: BaseViewController, View {
	typealias Reactor = HomeReactor
	// MARK: - Properties
	// MARK: - UI Components
	private lazy var contentView: UIView = UIView()

	func bind(reactor: HomeReactor) {
		bindState(reactor)
		bindAction(reactor)
	}
}
//MARK: - Action
extension PopupViewController {
	// MARK: 데이터 변경 요청 및 버튼 클릭시 요청 로직(View -> Reactor)
	private func bindAction(_ reactor: HomeReactor) {
	}
	
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: HomeReactor) {
		
	}
}
//MARK: - Attribute & Hierarchy & Layouts
extension PopupViewController {
	override func setAttribute() {
		super.setAttribute()
		
		view.backgroundColor = .clear
		
		contentView = contentView.then {
			$0.backgroundColor = R.Color.white
			$0.layer.cornerRadius = 16
		}
	}
	
	override func setHierarchy() {
		super.setHierarchy()

		view.addSubviews(contentView)
	}
	
	override func setLayout() {
		super.setLayout()
		
		contentView.snp.makeConstraints {
			$0.width.equalTo(312)
			$0.height.equalTo(392)
			$0.center.equalToSuperview()
		}
	}
}
