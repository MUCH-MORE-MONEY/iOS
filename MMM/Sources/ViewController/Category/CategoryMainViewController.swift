//
//  CategoryMainViewController.swift
//  MMM
//
//  Created by geonhyeong on 2023/08/23.
//

import Then
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import UIKit

// 상속하지 않으려면 final 꼭 붙이기
final class CategoryMainViewController: BaseViewControllerWithNav, View {
	typealias Reactor = CategoryMainReactor
	
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
	
    // 편집 뷰에서 들어온 경우를 판단하기 위한 변수
    var isEditView = false
    var editViewModel: EditActivityViewModel?
    
	// MARK: - UI Components
	private lazy var editButton = UIButton()
	private lazy var segmentedControl = CategorySegmentedControl(items: [R.Icon.minus16!.textEmbeded(text: "지출", font: R.Font.body0, color: R.Color.white, spacing: 8, leftMargin: 24), R.Icon.plus16!.textEmbeded(text: "수입", font: R.Font.body0, color: R.Color.white, spacing: 8, rightMargin: 24)])
	private lazy var pageViewController = UIPageViewController()
	private lazy var payViewController = CategoryContentViewController(mode: .pay)
	private lazy var earnViewController = CategoryContentViewController(mode: .earn)
	private var dataViewControllers: [UIViewController] {
		[self.payViewController, self.earnViewController]
	}
	private lazy var loadView = LoadingViewController()
	
	override func viewDidLoad() {
		super.viewDidLoad()
        Tracking.Category.mainPayLogEvent()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		reactor?.action.onNext(.refresh)
	}

	func bind(reactor: CategoryMainReactor) {
		bindState(reactor)
		bindAction(reactor)
	}
    
    // 편집 뷰에서 들어온 경우
    override func didTapBackButton() {
        super.didTapBackButton()
        
        if let viewModel = editViewModel {
            viewModel.isCategoryManageButtonTapped = false
            viewModel.isViewFromCategoryViewController = true
        }
    }
}

//MARK: - Bind
extension CategoryMainViewController {
	// MARK: 데이터 변경 요청 및 버튼 클릭시 요청 로직(View -> Reactor)
	private func bindAction(_ reactor: CategoryMainReactor) {
		editButton.rx.tap
			.subscribe(onNext: willPushEditViewController)
			.disposed(by: disposeBag)
		
		segmentedControl.rx.selectedSegmentIndex
            .skip(1)
			.map { $0 == 0 ? 0 : 1 }
			.subscribe(onNext: {
				self.currentPage = $0 // page 변경
                switch self.currentPage {
                case 0:
                    Tracking.Category.mainPayLogEvent()
                default:
                    Tracking.Category.mainEarnLogEvent()
                }
			})
			.disposed(by: disposeBag)
	}
	
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: CategoryMainReactor) {
		reactor.state
			.compactMap { $0.nextScreen }
			.subscribe(onNext: willPushViewController)
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
		
		// Toast Message 표시
		reactor.state
			.map { $0.isRrefresh }
			.distinctUntilChanged() // 중복값 무시
			.filter{ $0 } // 편집되었을 경우에만
			.withUnretained(self)
			.subscribe(onNext: { this, isRefresh in
				if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
					sceneDelegate.window?.showToast(message: "카테고리가 수정되었습니다")
				}
			})
			.disposed(by: disposeBag)
	}
}
//MARK: - Action
extension CategoryMainViewController {
	private func willPushViewController(categoryLowwer: CategoryLowwer) {
		guard let reactor = self.reactor else { return }

		let vc = CategoryDetailViewController()
		let type = segmentedControl.selectedSegmentIndex == 0 ? "01" : "02"
		let indexPath = reactor.currentState.indexPath ?? IndexPath(row: 0, section: 0)
		let section = segmentedControl.selectedSegmentIndex == 0 ? reactor.currentState.paySections[indexPath.section] : reactor.currentState.earnSections[indexPath.section]
		vc.reactor = CategoryDetailReactor(date: reactor.currentState.date, type: type, section: section.model.header, categoryLowwer: categoryLowwer)

		navigationController?.pushViewController(vc, animated: true)
	}
	
	private func willPushEditViewController() {
		guard let reactor = self.reactor else { return }

		let vc = CategoryEditViewController(mode: segmentedControl.selectedSegmentIndex == 0 ? .pay : .earn)
		vc.reactor = CategoryEditReactor(provider: reactor.provider, type: segmentedControl.selectedSegmentIndex == 0 ? "01" : "02")

		navigationController?.pushViewController(vc, animated: true)
	}
}
//MARK: - Attribute & Hierarchy & Layouts
extension CategoryMainViewController {
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
			$0.view.backgroundColor = R.Color.gray900
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
extension CategoryMainViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
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
