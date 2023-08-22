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

final class StatisticsViewController: UIViewController, View {
	// MARK: - Properties
	private var tabBarViewModel: TabBarViewModel
	var disposeBag: DisposeBag = DisposeBag()

	// MARK: - UI Components
	private lazy var monthButtonItem = UIBarButtonItem()
	private lazy var monthButton = SemanticContentAttributeButton()
	private lazy var scrollView = UIScrollView()
	private lazy var contentView = UIView()
	private lazy var headerView = StatisticsHeaderView()
	private lazy var satisfactionView = StatisticsSatisfactionView()
	private lazy var categoryView = StatisticsCategoryView()
	private lazy var activityView = StatisticsActivityView()
	private lazy var selectAreaView = StatisticsSatisfactionSelectView()

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
	
	// 초기 셋업할 코드들
	private func setup() {
		setAttribute()
		setLayout()
	}
	
	func bind(reactor: StatisticsReactor) {
		bindState(reactor)
		bindAction(reactor)
	}
}
//MARK: - Action
extension StatisticsViewController {
	// Bottom Sheet 설정
	private func showBottomSheet() {
		// 달력 Picker
		
	}
}
//MARK: - Bind
extension StatisticsViewController {
	// MARK: 데이터 변경 요청 및 버튼 클릭시 요청 로직(View -> Reactor)
	private func bindAction(_ reactor: StatisticsReactor) {
		monthButton.rx.tap
			.subscribe(onNext: { [weak self] _ in
				guard let self = self else { return }
				self.showBottomSheet() // '월' 변경 버튼
			}).disposed(by: self.disposeBag)
	}
	
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: StatisticsReactor) {

	}
}
//MARK: - Style & Layouts
extension StatisticsViewController {
	private func setAttribute() {
		view.backgroundColor = R.Color.gray900
		
		// Root View인 NavigationView에 item 수정하기
		if let navigationController = self.navigationController {
			if let rootVC = navigationController.viewControllers.first {
				rootVC.navigationItem.leftBarButtonItem = monthButtonItem
			}
		}
		
		scrollView = scrollView.then {
			$0.showsVerticalScrollIndicator = false // bar 숨기기
			$0.delaysContentTouches = false // highlight 효과가 작동
			$0.canCancelContentTouches = true
		}
			
		let view = UIView(frame: .init(origin: .zero, size: .init(width: 80, height: 30)))
		monthButton = monthButton.then {
			$0.frame = .init(origin: .init(x: 8, y: 0), size: .init(width: 80, height: 30))
			$0.setTitle(Date().getFormattedDate(format: "M월"), for: .normal)
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
	
	private func setLayout() {
		view.addSubview(scrollView)
		scrollView.addSubview(contentView)
		contentView.addSubviews(headerView, satisfactionView, categoryView, activityView, selectAreaView)
		
		scrollView.snp.makeConstraints {
			$0.top.leading.trailing.equalTo(view)
			$0.bottom.equalTo(view).inset(82) // TabBar Height
		}
		
		contentView.snp.makeConstraints {
			$0.edges.equalTo(scrollView)
			$0.leading.trailing.equalTo(view)
		}
		
		headerView.snp.makeConstraints {
			$0.top.equalToSuperview().inset(32)
			$0.leading.equalToSuperview().inset(24)
			$0.trailing.equalToSuperview().inset(20)
		}
		
		satisfactionView.snp.makeConstraints {
			$0.top.equalTo(headerView.snp.bottom)
			$0.leading.trailing.equalToSuperview().inset(20)
			$0.height.equalTo(64)
		}
		
		categoryView.snp.makeConstraints {
			$0.top.equalTo(satisfactionView.snp.bottom).offset(16)
			$0.leading.trailing.equalToSuperview().inset(20)
			$0.height.equalTo(113)
		}
		
		activityView.snp.makeConstraints {
			$0.top.equalTo(categoryView.snp.bottom).offset(16)
			$0.leading.trailing.equalToSuperview().inset(20)
			$0.height.equalTo(100)
		}
		
		selectAreaView.snp.makeConstraints {
			$0.top.equalTo(activityView.snp.bottom).offset(58)
			$0.leading.trailing.equalToSuperview()
			$0.bottom.equalTo(contentView)
			$0.height.equalTo(300)
		}
	}
}
