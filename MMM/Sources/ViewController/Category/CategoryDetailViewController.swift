//
//  CategoryDetailViewController.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/23.
//

import Then
import SnapKit
import RxSwift
import ReactorKit

// 상속하지 않으려면 final 꼭 붙이기
final class CategoryDetailViewController: BaseViewControllerWithNav, View {
	typealias Reactor = CategoryDetailReactor

	// MARK: - Constants
	private enum UI {
	}
	
	// MARK: - Properties
	
	// MARK: - UI Components
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	func bind(reactor: CategoryDetailReactor) {
		bindState(reactor)
		bindAction(reactor)
	}
}
//MARK: - Bind
extension CategoryDetailViewController {
	// MARK: 데이터 변경 요청 및 버튼 클릭시 요청 로직(View -> Reactor)
	private func bindAction(_ reactor: CategoryDetailReactor) {
	}
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: CategoryDetailReactor) {
		reactor.state
			.map { $0.category }
			.distinctUntilChanged() // 중복값 무시
			.subscribe(onNext: { [weak self] category in
				guard let self = self else { return }
				self.title = category.title
			})
			.disposed(by: disposeBag)
	}
}
//MARK: - Action
extension CategoryDetailViewController {
}
//MARK: - Attribute & Hierarchy & Layouts
extension CategoryDetailViewController {
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()
	}
	
	override func setHierarchy() {
		super.setHierarchy()
	}
	
	override func setLayout() {
		super.setLayout()
	}
}
