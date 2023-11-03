//
//  StatisticsViewController.swift
//  MMM
//
//  Created by geonhyeong on 2023/08/14.
//

import Then
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

// 상속하지 않으려면 final 꼭 붙이기
final class StatisticsViewController: BaseViewController, View {
	typealias Reactor = StatisticsReactor

	// MARK: - Constants
	private enum UI {
		static let sideMargin: CGFloat = 20
	}
	
	// MARK: - Properties
	private var month: Date = Date()
	private var satisfaction: Satisfaction = .low
	private var timer: DispatchSourceTimer? // rank(순위)를 변경하는 시간

	// MARK: - UI Components
	private lazy var monthButtonItem = UIBarButtonItem()
	private lazy var monthButton = SemanticContentAttributeButton()
	private lazy var headerView = UIView()
	private lazy var titleView = StatisticsTitleView()
	private lazy var satisfactionView = StatisticsAverageView()
	private lazy var categoryView = StatisticsCategoryView()
	private lazy var activityView = StatisticsActivityView(timer: timer)
	private lazy var selectView = StatisticsSatisfactionView() // 만족도 선택
	private lazy var tableView = UITableView()
	private lazy var refreshControl = RefreshControl()

	// Empty & Error UI
	private lazy var emptyView = HomeEmptyView()
	
    override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		// Root View인 NavigationView에 item 수정하기
		if let navigationController = self.navigationController {
			if let rootVC = navigationController.viewControllers.first {
				rootVC.navigationItem.leftBarButtonItem = monthButtonItem
				rootVC.navigationItem.rightBarButtonItem = nil
			}
		}
		
		timer?.resume() // 타이머 재시작
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		timer?.suspend() // 일시정지
	}

	func bind(reactor: StatisticsReactor) {
		bindState(reactor)
		bindAction(reactor)
	}
}
//MARK: - Bind
extension StatisticsViewController {
	// MARK: 데이터 변경 요청 및 버튼 클릭시 요청 로직(View -> Reactor)
	private func bindAction(_ reactor: StatisticsReactor) {
		monthButton.rx.tap
			.subscribe(onNext: { [weak self] _ in
				guard let self = self else { return }
				self.presentBottomSheet() // '월' 변경 버튼
			}).disposed(by: disposeBag)
		
		// TableView cell select
		Observable.zip(
			tableView.rx.itemSelected,
			tableView.rx.modelSelected(EconomicActivity.self)
		)
		.map { .selectCell($0, $1) }
		.bind(to: reactor.action)
		.disposed(by: disposeBag)
		
		// Refresh 작동 없애기
		refreshControl.rx.controlEvent(.valueChanged)
			.bind(onNext: { self.tableView.refreshControl?.endRefreshing()})
			.disposed(by: disposeBag)
		
		// pagination
		tableView.rx.didScroll
			.withLatestFrom(self.tableView.rx.contentOffset)
			.map { [weak self] in
				return .pagination(
					contentHeight: self?.tableView.contentSize.height ?? 0,
					contentOffsetY: $0.y,
					scrollViewHeight: UIScreen.main.bounds.height)
			}
			.bind(to: reactor.action)
			.disposed(by: disposeBag)
	}
	
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: StatisticsReactor) {
		
		reactor.state
			.map { $0.date }
			.distinctUntilChanged() // 중복값 무시
			.bind(onNext: setMonth) // '월' 변경
			.disposed(by: disposeBag)
		
		reactor.state
			.map { $0.average }
			.distinctUntilChanged() // 중복값 무시
			.bind(onNext: satisfactionView.setData) // 평균 변경
			.disposed(by: disposeBag)
		
		reactor.state
			.map { $0.satisfaction }
			.distinctUntilChanged() // 중복값 무시
			.bind(onNext: setSatisfaction) // 만족도 변경
			.disposed(by: disposeBag)
		
		reactor.state
			.map { $0.activityList }
			.distinctUntilChanged() // 중복값 무시
			.bind(to: tableView.rx.items) { tv, row, data in
				let index = IndexPath(row: row, section: 0)
				let cell = tv.dequeueReusableCell(withIdentifier: HomeTableViewCell.className, for: index) as! HomeTableViewCell
				
				// 데이터 설정
				cell.setData(data: data, last: row == reactor.currentState.activityList.count - 1)
				cell.backgroundColor = R.Color.gray100

				let backgroundView = UIView()
				backgroundView.backgroundColor = R.Color.gray400.withAlphaComponent(0.3)
				cell.selectedBackgroundView = backgroundView
				
				return cell
			}.disposed(by: disposeBag)
		
		// Empty case 여부 판별
		reactor.state
			.map { $0.activityList.isEmpty }
			.withUnretained(self)
			.distinctUntilChanged { $0.1 } // 중복값 무시
			.subscribe(onNext: { this, isEmpty in
				print("여기야", isEmpty)
//				this.emptyView.isHidden = !isEmpty
				this.tableView.tableFooterView = isEmpty ? this.emptyView : nil
			})
			.disposed(by: disposeBag)
		
		// 카테고리 더보기 클릭시, push
		reactor.state
			.map { $0.isPushMoreCategory }
			.distinctUntilChanged() // 중복값 무시
			.filter { $0 } // true일때만 화면 전환
			.bind(onNext: pushCategoryViewController)
			.disposed(by: disposeBag)
		
		// 만족도 선택시, present
		reactor.state
			.map { $0.isPresentSatisfaction }
			.distinctUntilChanged() // 중복값 무시
			.filter { $0 } // true일때만 화면 전환
			.bind(onNext: presentStisfactionViewController)
			.disposed(by: disposeBag)
		
		// Cell Click시, push
		reactor.state
			.map { $0.isPushDetail }
			.distinctUntilChanged() // 중복값 무시
			.filter { $0 } // true일때만 화면 전환
			.bind(onNext: pushDetail)
			.disposed(by: disposeBag)
	}
}
//MARK: - Action
extension StatisticsViewController {
	// Bottom Sheet 설정
	private func presentBottomSheet() {
		guard let reactor = self.reactor else { return }
		// 달력 Picker
		let vc = DateBottomSheetViewController(title: "월 이동", date: month, height: 360, mode: .onlyMonthly, sheetMode: .drag, isDark: false)
		vc.reactor = DateBottomSheetReactor(provider: reactor.provider)
		self.present(vc, animated: true, completion: nil)
	}
	
	// 카테고리 더보기
	private func pushCategoryViewController(_ isPush: Bool) {
		guard let reactor = self.reactor else { return }

		let vc = CategoryMainViewController()
		vc.reactor = CategoryMainReactor(provider: reactor.provider, date: reactor.currentState.date)
		navigationController?.pushViewController(vc, animated: true)
	}
	
	// Cell의 Detail View
	private func pushDetail(_ isPush: Bool) {
		guard let reactor = reactor, let data = reactor.currentState.detailData else { return }
		
		// 셀 터치시 회색 표시 없애기
		tableView.deselectRow(at: data.IndexPath, animated: true)

		let index = data.IndexPath.row
		let vc = DetailViewController(homeViewModel: HomeViewModel(), index: index) // 임시: HomeViewModel 생성
		let economicActivityId = reactor.currentState.activityList.map { $0.id }
		vc.setData(economicActivityId: economicActivityId, index: index, date: data.info.createAt.toDate() ?? Date())
		
		navigationController?.pushViewController(vc, animated: true)
	}
	
	// 만족도 보기
	private func presentStisfactionViewController(_ isPresent: Bool) {
		guard let reactor = self.reactor else { return }

		let vc = SatisfactionBottomSheetViewController(title: "만족도 모아보기", satisfaction: satisfaction, height: 276)
		vc.reactor = SatisfactionBottomSheetReactor(provider: reactor.provider)

		self.present(vc, animated: true, completion: nil)
	}
	
	/// '월'  및 범위 변경
	private func setMonth(_ date: Date) {
		// 올해인지 판별
		if Date().getFormattedDate(format: "yyyy") != date.getFormattedDate(format: "yyyy") {
			monthButton.setTitle(date.getFormattedDate(format: "yyyy년 M월"), for: .normal)
		} else {
			monthButton.setTitle(date.getFormattedDate(format: "M월"), for: .normal)
		}
		
		// 범위 변경
		let month = date.getFormattedDate(format: "MM")
		var end = date.lastDay() ?? "01"
		
		// 이번달 인지 판별
		if date.getFormattedYM() == Date().getFormattedYM() {
			end = Date().getFormattedDate(format: "dd")
		}
		
		self.titleView.setData(startDate: "\(month).01", endDate: "\(month).\(end)")
		self.month = date
	}
	
	/// 만족도  변경
	private func setSatisfaction(_ satisfaction: Satisfaction) {
		selectView.setData(title: satisfaction.title, score: satisfaction.score)
		self.satisfaction = satisfaction
	}
}
//MARK: - Attribute & Hierarchy & Layouts
extension StatisticsViewController {
	// 초기 셋업할 코드들
	override func setup() {
		setTimer()
		super.setup()
	}
	
	private func setTimer() {
		timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
		timer?.schedule(deadline: .now(), repeating: 1)
	}
	
	override func setAttribute() {
		super.setAttribute()
		
		view.backgroundColor = R.Color.gray900
		
		headerView.backgroundColor = R.Color.gray900
		categoryView.reactor = self.reactor // reactor 주입
		activityView.reactor = self.reactor // reactor 주입
		selectView.reactor = self.reactor // reactor 주입
		
		let view = UIView(frame: .init(origin: .zero, size: .init(width: 150, height: 30)))
		monthButton = monthButton.then {
			$0.frame = .init(origin: .init(x: 8, y: 0), size: .init(width: 150, height: 30))
			$0.setTitle(month.getFormattedDate(format: "M월"), for: .normal)
			$0.setImage(R.Icon.arrowExpandMore16, for: .normal)
			$0.setTitleColor(R.Color.white, for: .normal)
			$0.setTitleColor(R.Color.white.withAlphaComponent(0.7), for: .highlighted)
			$0.imageView?.contentMode = .scaleAspectFit
			$0.titleLabel?.font = R.Font.h5
			$0.contentHorizontalAlignment = .left
			$0.imageEdgeInsets = .init(top: 0, left: 8, bottom: 0, right: 0) // 이미지 여백
		}
		view.addSubview(monthButton)

		monthButtonItem = monthButtonItem.then {
			$0.customView = view
		}
		
		refreshControl = refreshControl.then {
			$0.tintColor = .clear
			$0.backgroundColor = R.Color.gray900
			$0.transform = CGAffineTransformMakeScale(0.5, 0.5)
		}
		
		tableView = tableView.then {
			$0.register(HomeTableViewCell.self)
			$0.refreshControl = refreshControl
			$0.tableHeaderView = headerView
			$0.tableFooterView = emptyView
			$0.backgroundColor = R.Color.gray100
			$0.showsVerticalScrollIndicator = false
			$0.separatorStyle = .none
			$0.rowHeight = UITableView.automaticDimension
		}
		
		headerView = headerView.then {
			$0.frame = .init(x: 0, y: 0, width: view.bounds.width, height: 590)
		}
		
		emptyView = emptyView.then {
			$0.frame = .init(x: 0, y: 0, width: view.bounds.width, height: 248)
		}
	}
	
	override func setHierarchy() {
		super.setHierarchy()
		
		view.addSubviews(tableView)
		headerView.addSubviews(titleView, satisfactionView, categoryView, activityView, selectView)
	}
	
	override func setLayout() {
		super.setLayout()
		
		titleView.snp.makeConstraints {
			$0.top.equalToSuperview().inset(32)
			$0.leading.equalToSuperview().inset(24)
			$0.trailing.equalToSuperview().inset(UI.sideMargin)
		}
		
		satisfactionView.snp.makeConstraints {
			$0.top.equalTo(titleView.snp.bottom)
			$0.leading.trailing.equalToSuperview().inset(UI.sideMargin)
			$0.height.equalTo(64)
		}

		categoryView.snp.makeConstraints {
			$0.top.equalTo(satisfactionView.snp.bottom).offset(16)
			$0.leading.trailing.equalToSuperview().inset(UI.sideMargin)
			$0.height.equalTo(146)
		}

		activityView.snp.makeConstraints {
			$0.top.equalTo(categoryView.snp.bottom).offset(16)
			$0.leading.trailing.equalToSuperview().inset(UI.sideMargin)
			$0.height.equalTo(100)
		}

		selectView.snp.makeConstraints {
			$0.top.equalTo(activityView.snp.bottom).offset(58)
			$0.leading.trailing.equalToSuperview()
			$0.bottom.equalToSuperview()
		}
		
		// Table View
		tableView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
	}
}
