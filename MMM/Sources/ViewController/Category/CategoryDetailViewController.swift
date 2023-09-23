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
	private lazy var tableView = UITableView()

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
		// TableView cell select
		Observable.zip(
			tableView.rx.itemSelected,
			tableView.rx.modelSelected(EconomicActivity.self)
		)
		.map { .selectCell($0, $1) }
		.bind(to: reactor.action)
		.disposed(by: disposeBag)
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
		
		reactor.state
			.map { $0.list }
			.distinctUntilChanged() // 중복값 무시
			.bind(to: tableView.rx.items) { tv, row, data in
				let index = IndexPath(row: row, section: 0)
				let cell = tv.dequeueReusableCell(withIdentifier: HomeTableViewCell.className, for: index) as! HomeTableViewCell
				
				// 데이터 설정
				cell.setData(data: data, last: row == reactor.currentState.list.count - 1)
				cell.backgroundColor = R.Color.gray100

				let backgroundView = UIView()
				backgroundView.backgroundColor = R.Color.gray400.withAlphaComponent(0.3)
				cell.selectedBackgroundView = backgroundView
				
				return cell
			}.disposed(by: disposeBag)
		
		reactor.state
			.map { $0.isPushDetail }
			.distinctUntilChanged() // 중복값 무시
			.filter { $0 } // true일때만 화면 전환
			.bind(onNext: willPushViewController)
			.disposed(by: disposeBag)
	}
}
//MARK: - Action
extension CategoryDetailViewController {
	private func willPushViewController(isPushDetail: Bool) {
		guard let reactor = reactor, let data = reactor.currentState.detailData else { return }

		let index = data.IndexPath.row
		let vc = DetailViewController(homeViewModel: HomeViewModel(), index: index) // 임시: HomeViewModel 생성
		let economicActivityId = reactor.currentState.list.map { $0.id }
		vc.setData(economicActivityId: economicActivityId, index: index, date: data.info.createAt.toDate() ?? Date())
		
		navigationController?.pushViewController(vc, animated: true)
	}
}
//MARK: - Attribute & Hierarchy & Layouts
extension CategoryDetailViewController {
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()
		
		tableView = tableView.then {
			$0.register(HomeTableViewCell.self)
			$0.backgroundColor = R.Color.gray100
			$0.showsVerticalScrollIndicator = false
			$0.separatorStyle = .none
			$0.rowHeight = UITableView.automaticDimension
		}
	}
	
	override func setHierarchy() {
		super.setHierarchy()
		
		view.addSubviews(tableView)
	}
	
	override func setLayout() {
		super.setLayout()
		
		tableView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
	}
}
