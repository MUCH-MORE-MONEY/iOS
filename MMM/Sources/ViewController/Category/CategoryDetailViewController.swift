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
	private lazy var titleStackView = UIStackView()
	private lazy var titleLabel = UILabel()
	private lazy var titleDescriptionLabel = UILabel()
	private lazy var tableView = UITableView()
	private lazy var loadView = LoadingViewController()
	private lazy var emptyView = CategoryEmptyView()
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		guard let reactor = reactor else { return }
		super.viewWillAppear(animated)
		
		// 뷰가 최초 로드 될 경우
		reactor.action.onNext(.loadData)
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
			.map { $0.categoryLowwer }
			.distinctUntilChanged() // 중복값 무시
			.subscribe(onNext: { [weak self] categoryLowwer in
				guard let self = self, let reactor = self.reactor else { return }
				let section = reactor.currentState.section
				self.titleLabel.text = section.dateYM.suffix(2) + "월 " + categoryLowwer.title
				self.titleDescriptionLabel.text = categoryLowwer.total.withCommas() + " 원"
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
			.map { $0.list.isEmpty }
			.withUnretained(self)
			.distinctUntilChanged { $0.1 } // 중복값 무시
			.subscribe(onNext: { this, isEmpty in
				this.emptyView.isHidden = !isEmpty
			})
			.disposed(by: disposeBag)
		
		reactor.state
			.map { $0.isPushDetail }
			.distinctUntilChanged() // 중복값 무시
			.filter { $0 } // true일때만 화면 전환
			.bind(onNext: willPushViewController)
			.disposed(by: disposeBag)
		
		// 로딩 발생
		reactor.state
			.map { $0.isLoading }
			.distinctUntilChanged() // 중복값 무시
			.subscribe(onNext: { [weak self] loading in
				guard let self = self else { return }
				
				if loading && !self.loadView.isPresent {
					self.loadView.play()
					self.loadView.isPresent = true
					self.loadView.modalPresentationStyle = .overFullScreen
					self.present(self.loadView, animated: false, completion: nil)
				} else {
					self.loadView.dismiss(animated: false)
				}
			})
			.disposed(by: disposeBag)
	}
}
//MARK: - Action
extension CategoryDetailViewController {
	private func willPushViewController(isPushDetail: Bool) {
		guard let reactor = reactor, let data = reactor.currentState.detailData else { return }
		
		// 셀 터치시 회색 표시 없애기
		tableView.deselectRow(at: data.IndexPath, animated: true)

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
		
		navigationItem.titleView = titleStackView

		// Navigation Title View
		titleStackView = titleStackView.then {
			$0.axis = .vertical
			$0.spacing = 4
		}
		
		titleLabel = titleLabel.then {
			$0.font = R.Font.title3
			$0.textColor = R.Color.white
			$0.textAlignment = .center
		}
		
		titleDescriptionLabel = titleDescriptionLabel.then {
			$0.font = R.Font.body3
			$0.textColor = R.Color.gray500
			$0.textAlignment = .center
		}
		
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
		
		titleStackView.addArrangedSubviews(titleLabel, titleDescriptionLabel)
		view.addSubviews(tableView, emptyView)
	}
	
	override func setLayout() {
		super.setLayout()
		
		tableView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
		
		emptyView.snp.makeConstraints {
			$0.center.equalToSuperview()
		}
	}
}
