//
//  StatisticsViewController.swift
//  MMM
//
//  Created by geonhyeong on 2023/08/14.
//

import Then
import SnapKit
import RxSwift
import ReactorKit

final class StatisticsViewController: UIViewController, View {
	// MARK: - Properties
	private var tabBarViewModel: TabBarViewModel
	var disposeBag: DisposeBag = DisposeBag()
	var reactor: StatisticsReactor? = StatisticsReactor()

	// MARK: - UI Components
	private lazy var monthButtonItem = UIBarButtonItem()
	private lazy var monthButton = SemanticContentAttributeButton()

	init(tabBarViewModel: TabBarViewModel) {
		self.tabBarViewModel = tabBarViewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	// Compile time에 error를 발생시키는 코드
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setup()		// 초기 셋업할 코드들
    }
}
//MARK: - Style & Layouts
extension StatisticsViewController {
	// 초기 셋업할 코드들
	private func setup() {
		setAttribute()
		setLayout()
	}
	
	func bind(reactor: StatisticsReactor) {
		bindState(reactor)
		bindAction(reactor)
	}
	
	// MARK: 데이터 변경 요청 및 버튼 클릭시 요청 로직(View -> Reactor)
	private func bindAction(_ reacotr: StatisticsReactor) {
	
	}
	
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: StatisticsReactor) {
//		reactor.state
//			.map { $0.isLoading }
//			.distinctUntilChanged()
//			.subscribe { isLoading in
//				print("loading ui ")
//			}
//			.disposed(by: disposeBag)
//
//		reactor.state
//			.map { $0.list }
//			.subscribe { list in
//				print("list binding ")
//			}
//			.disposed(by: disposeBag)
	}
		
	private func setAttribute() {
	}
	
	private func setLayout() {
	}
}
