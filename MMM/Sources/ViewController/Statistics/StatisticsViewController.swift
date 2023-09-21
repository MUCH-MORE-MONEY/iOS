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
	private lazy var scrollView = UIScrollView()
	private lazy var contentView = UIView()
	private lazy var refreshView = UIView()
	private lazy var headerView = StatisticsHeaderView()
	private lazy var satisfactionView = StatisticsAverageView()
	private lazy var categoryView = StatisticsCategoryView()
	private lazy var activityView = StatisticsActivityView(timer: timer)
	private lazy var listView = StatisticsSatisfactionListView()
	
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
		reactor?.action.onNext(.loadData) // 데이터 가져오기
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
	}
	
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: StatisticsReactor) {
		
		reactor.state
			.map { $0.date }
			.distinctUntilChanged() // 중복값 무시
			.bind(onNext: setMonth) // '월' 변경
			.disposed(by: disposeBag)
		
		reactor.state
			.map { $0.satisfaction }
			.distinctUntilChanged() // 중복값 무시
			.bind(onNext: setSatisfaction) // 만족도 변경
			.disposed(by: disposeBag)
		
		reactor.state
			.map { $0.average }
			.distinctUntilChanged() // 중복값 무시
			.bind(onNext: satisfactionView.setData) // 평균 변경
			.disposed(by: disposeBag)

		// 카테고리 더보기 클릭시, push
		reactor.state
			.map { $0.isPushMoreCartegory }
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
		let vc = CategoryViewController()
		vc.reactor = CategoryReactor()
		navigationController?.pushViewController(vc, animated: true)
	}
	
	// 카테고리 더보기
	private func pushDetail(_ isPush: Bool) {
		guard let reactor = reactor, let data = reactor.currentState.detailData else { return }
		
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
		
		self.headerView.setData(startDate: "\(month).01", endDate: "\(month).\(end)")
		self.month = date
	}
	
	/// 만족도  변경
	private func setSatisfaction(_ satisfaction: Satisfaction) {
		listView.setData(title: satisfaction.title, score: satisfaction.score)
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
		
		view.backgroundColor = R.Color.gray100
		
		scrollView = scrollView.then {
			$0.showsVerticalScrollIndicator = false // bar 숨기기
			$0.delaysContentTouches = false // highlight 효과가 작동
			$0.canCancelContentTouches = true
		}
		
		refreshView.backgroundColor = R.Color.gray900
		contentView.backgroundColor = R.Color.gray900
		categoryView.reactor = self.reactor // reactor 주입
		activityView.reactor = self.reactor // reactor 주입
		listView.reactor = self.reactor // reactor 주입
		
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
	}
	
	override func setHierarchy() {
		super.setHierarchy()
		
		view.addSubviews(scrollView)
		scrollView.addSubviews(refreshView, contentView)
		contentView.addSubviews(headerView, satisfactionView, categoryView, activityView, listView)
	}
	
	override func setLayout() {
		super.setLayout()
		
		scrollView.snp.makeConstraints {
			$0.top.leading.trailing.equalTo(view)
			$0.bottom.equalTo(view.safeAreaLayoutGuide)
		}
		
		refreshView.snp.makeConstraints {
			$0.top.leading.trailing.equalTo(view)
			$0.bottom.greaterThanOrEqualTo(contentView.snp.top)
		}
		
		contentView.snp.makeConstraints {
			$0.top.bottom.equalTo(scrollView)
			$0.leading.trailing.equalTo(view)
		}
		
		headerView.snp.makeConstraints {
			$0.top.equalToSuperview().inset(32)
			$0.leading.equalToSuperview().inset(24)
			$0.trailing.equalToSuperview().inset(UI.sideMargin)
		}
		
		satisfactionView.snp.makeConstraints {
			$0.top.equalTo(headerView.snp.bottom)
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
		
		listView.snp.makeConstraints {
			$0.top.equalTo(activityView.snp.bottom).offset(58)
			$0.leading.trailing.equalToSuperview()
			$0.bottom.equalTo(contentView)
			$0.height.equalTo(300)
		}
	}
}
