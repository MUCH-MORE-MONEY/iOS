//
//  CategoryContentViewController.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/15.
//

import Then
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

final class CategoryContentViewController: BaseViewController, View {
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
extension CategoryContentViewController {
}
//MARK: - Bind
extension CategoryContentViewController {
	// MARK: 데이터 변경 요청 및 버튼 클릭시 요청 로직(View -> Reactor)
	private func bindAction(_ reactor: CategoryReactor) {
	}
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: CategoryReactor) {
	}
}
//MARK: - Style & Layouts
extension CategoryContentViewController {
	// 초기 셋업할 코드들
	private func setup() {
		setAttribute()
		setLayout()
	}
	
	private func setAttribute() {
	}
	private func setLayout() {
	}
}
