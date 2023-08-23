//
//  CategoryViewController.swift
//  MMM
//
//  Created by geonhyeong on 2023/08/23.
//

import Then
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

final class CategoryViewController: BaseViewController, View {
	typealias Reactor = CategoryReactor
	
	// MARK: - Properties
	var disposeBag: DisposeBag = DisposeBag()

	// MARK: - UI Components

	override func viewDidLoad() {
		super.viewDidLoad()
		setup()		// 초기 셋업할 코드들
	}
	
	func bind(reactor: CategoryReactor) {
		bindState(reactor)
		bindAction(reactor)
	}
}
//MARK: - Action
extension CategoryViewController {
}
//MARK: - Bind
extension CategoryViewController {
	// MARK: 데이터 변경 요청 및 버튼 클릭시 요청 로직(View -> Reactor)
	private func bindAction(_ reactor: CategoryReactor) {
	}
	
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: CategoryReactor) {
	}
}
//MARK: - Style & Layouts
extension CategoryViewController {
	// 초기 셋업할 코드들
	private func setup() {
		setAttribute()
		setLayout()
	}
	
	private func setAttribute() {
		view.backgroundColor = R.Color.gray900
		title = "카테고리"
	}
	
	private func setLayout() {
	}
}
