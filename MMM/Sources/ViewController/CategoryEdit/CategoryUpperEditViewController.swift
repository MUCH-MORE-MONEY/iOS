//
//  CategoryUpperEditViewController.swift
//  MMM
//
//  Created by geonhyeong on 10/7/23.
//

import Then
import SnapKit
import RxSwift
import ReactorKit

// 상속하지 않으려면 final 꼭 붙이기
final class CategoryUpperEditViewController: BaseViewControllerWithNav, View {
	typealias Reactor = CategoryEditReactor

	// MARK: - Constants
	private enum UI {
	}
	
	// MARK: - Properties
	
	// MARK: - UI Components
	private lazy var checkButton = UIButton()
	private lazy var tableView = UITableView()

	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	func bind(reactor: CategoryEditReactor) {
		bindState(reactor)
		bindAction(reactor)
	}
}
//MARK: - Bind
extension CategoryUpperEditViewController {
	// MARK: 데이터 변경 요청 및 버튼 클릭시 요청 로직(View -> Reactor)
	private func bindAction(_ reactor: CategoryEditReactor) {
		checkButton.rx.tap
			.subscribe(onNext: {
				self.navigationController?.popViewController(animated: true)
			}).disposed(by: disposeBag)
		
		// TableView cell select
	}
	
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: CategoryEditReactor) {
		reactor.state
			.map { $0.sections.map { $0.model.header }.filter { $0.id != "footer" } }
			.distinctUntilChanged() // 중복값 무시
			.bind(to: tableView.rx.items) { tv, row, data in
				let index = IndexPath(row: row, section: 0)
				let cell = tv.dequeueReusableCell(withIdentifier: CategoryEditTableViewCell.className, for: index) as! CategoryEditTableViewCell
				
				// 데이터 설정
				cell.setData(last: row == reactor.currentState.sections.map { $0.model.header }.count - 2)
				cell.reactor = CategoryEditTableViewCellReactor(provider: reactor.provider, categoryHeader: data)

				let backgroundView = UIView()
				backgroundView.backgroundColor = .clear
				cell.selectedBackgroundView = backgroundView
				
				return cell
			}.disposed(by: disposeBag)
	}
}
//MARK: - Action
extension CategoryUpperEditViewController {
}
//MARK: - Attribute & Hierarchy & Layouts
extension CategoryUpperEditViewController {
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()
		
		navigationItem.title = "카테고리 유형 편집"
		navigationItem.rightBarButtonItem = UIBarButtonItem(customView: checkButton)
		view.backgroundColor = R.Color.gray900

		// Navigation Bar Right Button
		checkButton = checkButton.then {
			$0.setTitle("확인", for: .normal)
			$0.setTitleColor(R.Color.white.withAlphaComponent(0.7), for: .highlighted)
			$0.titleLabel?.font = R.Font.body1
		}
		
		tableView = tableView.then {
			$0.register(CategoryEditTableViewCell.self)
			$0.backgroundColor = R.Color.gray900
			$0.showsVerticalScrollIndicator = false
			$0.separatorStyle = .none
			$0.rowHeight = 56
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
