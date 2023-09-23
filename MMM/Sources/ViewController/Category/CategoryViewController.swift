//
//  CategoryViewController.swift
//  MMM
//
//  Created by geonhyeong on 2023/08/23.
//

import Then
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

// 상속하지 않으려면 final 꼭 붙이기
final class CategoryViewController: BaseViewControllerWithNav, View {
	typealias Reactor = CategoryReactor
	
	// MARK: - Constants
	private enum UI {
		static let segmentedControlHeight: CGFloat = 50
	}
	
	// MARK: - Properties
	private lazy var currentPage: Int = 0 { // 현재 선택된 page (지출/수입)
		didSet {
			// from segmentedControl -> pageViewController 업데이트
			let direction: UIPageViewController.NavigationDirection = oldValue <= self.currentPage ? .forward : .reverse
			self.pageViewController.setViewControllers([dataViewControllers[self.currentPage]], direction: direction, animated: true, completion: nil)
		}
	}
	
	// MARK: - UI Components
	private lazy var editButton = UIButton()
	private lazy var segmentedControl = CategorySegmentedControl(items: ["지출", "수입"])
	private lazy var pageViewController = UIPageViewController()
	private lazy var payViewController = CategoryContentViewController(mode: .pay)
	private lazy var earnViewController = CategoryContentViewController(mode: .earn)
	private var dataViewControllers: [UIViewController] {
		[self.payViewController, self.earnViewController]
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	func bind(reactor: CategoryReactor) {
		bindState(reactor)
		bindAction(reactor)
	}
}
//MARK: - Bind
extension CategoryViewController {
	// MARK: 데이터 변경 요청 및 버튼 클릭시 요청 로직(View -> Reactor)
	private func bindAction(_ reactor: CategoryReactor) {
		editButton.rx.tap
			.subscribe(onNext: {
//				guard let self = self else { return }
			}).disposed(by: disposeBag)
		
		segmentedControl.rx.selectedSegmentIndex
			.map { $0 == 0 ? 0 : 1 }
			.subscribe(onNext: {
				self.currentPage = $0 // page 변경
			})
			.disposed(by: disposeBag)
	}
	
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: CategoryReactor) {
		reactor.state
			.map { $0.nextScreen }
			.distinctUntilChanged() // 중복값 무시
			.filter { $0 } // true일때만 화면 전환
			.subscribe(onNext: { [weak self] _ in
				self?.willPushViewController()
			})
			.disposed(by: disposeBag)
	}
}
//MARK: - Action
extension CategoryViewController {
	private func willPushViewController() {
		print(#file, #line, "push")
//		let viewController =
//
//		navigationController?.pushViewController(viewController, animated: true)
	}
}
//MARK: - Attribute & Hierarchy & Layouts
extension CategoryViewController {
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()
		
		title = "카테고리"
		view.backgroundColor = R.Color.gray900
		navigationItem.rightBarButtonItem = UIBarButtonItem(customView: editButton)
		
		// Navigation Bar Right Button
		editButton = editButton.then {
			$0.setTitle("편집", for: .normal)
			$0.setTitleColor(R.Color.white.withAlphaComponent(0.7), for: .highlighted)
			$0.titleLabel?.font = R.Font.body1
		}
		
		segmentedControl = segmentedControl.then {
			$0.backgroundColor = R.Color.gray900
			$0.selectedSegmentIndex = 0
			$0.translatesAutoresizingMaskIntoConstraints = true
			$0.setTitleTextAttributes([.foregroundColor: R.Color.gray500, .font: R.Font.title1], for: .normal)
			$0.setTitleTextAttributes([.foregroundColor: R.Color.white, .font: R.Font.title1], for: .selected)
		}
		
		pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil).then {
			$0.setViewControllers([self.dataViewControllers[0]], direction: .forward, animated: true)
			$0.delegate = self
			$0.dataSource = self
			$0.view.translatesAutoresizingMaskIntoConstraints = false
		}
		
		payViewController = payViewController.then {
			$0.reactor = reactor
		}
		
		earnViewController = earnViewController.then {
			$0.reactor = reactor
		}
	}
	
	override func setHierarchy() {
		super.setHierarchy()
		
		view.addSubviews(segmentedControl, pageViewController.view)
	}
	
	override func setLayout() {
		super.setLayout()
		
		segmentedControl.snp.makeConstraints {
			$0.top.equalToSuperview()
			$0.leading.trailing.equalToSuperview()
			$0.height.equalTo(UI.segmentedControlHeight)
		}
		
		pageViewController.view.snp.makeConstraints {
			$0.top.equalTo(segmentedControl.snp.bottom)
			$0.leading.trailing.bottom.equalToSuperview()
		}
	}
}
//MARK: - UIPageViewController DataSource, Delegate
extension CategoryViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		guard let index = self.dataViewControllers.firstIndex(of: viewController), index - 1 >= 0 else { return nil }
		return self.dataViewControllers[index - 1]
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		guard let index = self.dataViewControllers.firstIndex(of: viewController), index + 1 < self.dataViewControllers.count else { return nil }
		return self.dataViewControllers[index + 1]
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool,previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		guard let viewController = pageViewController.viewControllers?[0], let index = self.dataViewControllers.firstIndex(of: viewController) else { return }
		self.currentPage = index
		self.segmentedControl.selectedSegmentIndex = index
	}
}
