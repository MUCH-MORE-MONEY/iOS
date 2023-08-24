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
	typealias Reactor = StatisticsReactor

	// MARK: - Properties
	var disposeBag: DisposeBag = DisposeBag()
	var bottomSheetReactor: BottomSheetReactor = BottomSheetReactor()

	// MARK: - UI Components
	private lazy var monthButtonItem = UIBarButtonItem()
	private lazy var monthButton = SemanticContentAttributeButton()
	private lazy var scrollView = UIScrollView()
	private lazy var contentView = UIView()
	private lazy var refreshView = UIView()
	private lazy var headerView = StatisticsHeaderView()
	private lazy var satisfactionView = StatisticsSatisfactionView()
	private lazy var categoryView = StatisticsCategoryView()
	private lazy var activityView = StatisticsActivityView()
	private lazy var selectAreaView = StatisticsSatisfactionListView()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setup()		// 초기 셋업할 코드들
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setNavigationBarHidden(false, animated: false)
		
		// Root View인 NavigationView에 item 수정하기
		if let navigationController = self.navigationController {
			if let rootVC = navigationController.viewControllers.first {
				rootVC.navigationItem.leftBarButtonItem = monthButtonItem
				rootVC.navigationItem.rightBarButtonItem = nil
			}
		}
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
		bottomSheetReactor.state
			.map { $0.success }
			.distinctUntilChanged() // 중복값 무시
			.bind(onNext: setMonth) // '월' 변경
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
	}
}
//MARK: - Action
extension StatisticsViewController {
	// Bottom Sheet 설정
	private func presentBottomSheet() {
		// 달력 Picker
		let vc = DatePicker2ViewController()
		let bottomSheetVC = BottomSheetViewController(contentViewController: vc)
		vc.reactor = bottomSheetReactor
		vc.setData(title: "월 이동")
		vc.delegate = bottomSheetVC
		bottomSheetVC.modalPresentationStyle = .overFullScreen
		bottomSheetVC.setSetting(height: 360)
		self.present(bottomSheetVC, animated: false, completion: nil) // fasle(애니메이션 효과로 인해 부자연스럽움 제거)
	}
	
	// 카테고리 더보기
	private func pushCategoryViewController(_ isPresent: Bool) {
		let vc = CategoryViewController()
		navigationController?.pushViewController(vc, animated: true)
	}
	
	// 만족도 보기
	private func presentStisfactionViewController(_ isPresent: Bool) {
		// 달력 Picker
		let vc = StatisticsSatisfactionSelectViewController(satisfaction: .low)
		let bottomSheetVC = BottomSheetViewController(contentViewController: vc)
		vc.reactor = bottomSheetReactor
		vc.setData(title: "만족도 모아보기")
		vc.delegate = bottomSheetVC
		bottomSheetVC.modalPresentationStyle = .overFullScreen
		bottomSheetVC.setSetting(height: 276)
		self.present(bottomSheetVC, animated: false, completion: nil) // fasle(애니메이션 효과로 인해 부자연스럽움 제거)
	}
	
	/// '월'  변경
	private func setMonth(_ date: Date) {
		// 올해인지 판별
		if Date().getFormattedDate(format: "yyyy") != date.getFormattedDate(format: "yyyy") {
			monthButton.setTitle(date.getFormattedDate(format: "yyyy년 M월"), for: .normal)
		} else {
			monthButton.setTitle(date.getFormattedDate(format: "M월"), for: .normal)
		}
	}
}
//MARK: - Style & Layouts
extension StatisticsViewController {
	// 초기 셋업할 코드들
	private func setup() {
		setAttribute()
		setLayout()
	}
	
	private func setAttribute() {
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
		selectAreaView.reactor = self.reactor // reactor 주입
		
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
		view.addSubviews(scrollView)
		scrollView.addSubviews(refreshView, contentView)
		contentView.addSubviews(headerView, satisfactionView, categoryView, activityView, selectAreaView)
		
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
