//
//  HomeViewController.swift
//  MMM
//
//  Created by geonhyeong on 2023/04/12.
//

import UIKit
import Combine
import Then
import SnapKit
import FSCalendar
import Lottie
import FirebaseAnalytics

final class HomeViewController: UIViewController {
	// MARK: - Properties
	private lazy var cancellable: Set<AnyCancellable> = .init()
	private let viewModel = HomeViewModel()
	private lazy var preDate = Date() // yyyyMMdd
    private var tabBarViewModel: TabBarViewModel

	// MARK: - UI Components
	private lazy var monthButtonItem = UIBarButtonItem()
	private lazy var monthButton = SemanticContentAttributeButton()
	private lazy var rightBarItem = UIBarButtonItem()
	private lazy var righthStackView = UIStackView()
	private lazy var todayButton = UIButton()
	private lazy var filterButton = UIButton()
	private lazy var separator = UIView() // Nav separator
	private lazy var calendar = FSCalendar()
	private lazy var calendarHeaderView = HomeHeaderView()
	private lazy var tableView = UITableView()
	private lazy var headerView = UIView()
	private lazy var dayLabel = UILabel()
	private lazy var scopeGesture = UIPanGestureRecognizer()
	private lazy var loadView = LoadingViewController()

	// Empty & Error UI
	private lazy var emptyView = HomeEmptyView()
	private lazy var errorBgView = UIView()
	private lazy var monthlyErrorView = HomeErrorView()
	private lazy var dailyErrorView = HomeErrorView()
	private lazy var retryButton = UIButton()
	
    init(tabBarViewModel: TabBarViewModel) {
        self.tabBarViewModel = tabBarViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
	override func viewDidLoad() {
		super.viewDidLoad()
		setup()		// 초기 셋업할 코드들
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		fetchData()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
	}
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        Analytics.setUserID("userID = \(1234)")
//        Analytics.logEvent(AnalyticsEventScreenView, parameters: nil)
//        Analytics.logEvent("메인화면", parameters: nil)
    }
}
//MARK: - Action
extension HomeViewController {
	// 오늘 날짜로 돌아오기
	func didTapTodayButton() {
		self.didSelectDate(Date())
	}
	
	// 날짜 선택
	func didSelectDate(_ date: Date) {
		self.calendar.select(date)
		self.dayLabel.text = date.getFormattedDate(format: "dd일 (EEEEE)") // 선택된 날짜
		self.preDate = date
		self.viewModel.getDailyList(date.getFormattedYMD())
		self.setMonth(date)
		self.viewModel.preDate = date
	}
	
	// MARK: - Private
	/// 데이터 얻기
	private func fetchData() {
		viewModel.isWillAppear = true // viewWillAppear 일 경우에만 Loading 표시
		if calendar.scope == .month { // 월 단위
			viewModel.getMonthlyList(calendar.currentPage.getFormattedYM())
		} else { // 주 단위
			if let dateAfter = Calendar.current.date(byAdding: .day, value: 6, to: calendar.currentPage) { // 해당 주의 마지막 날짜
				let date = calendar.currentPage.getFormattedYM()
				if date != dateAfter.getFormattedYM() { // 마지막 날짜 비교
					viewModel.getWeeklyList(date, dateAfter.getFormattedYM())
				}
			}
		}
		viewModel.getDailyList(preDate.getFormattedYMD())
		calendar.reloadData()
		tableView.reloadData()
		viewModel.isWillAppear = false
	}
	
	/// 달력 Picker Bottom Sheet
	private func didTapMonthButton() {
		let picker = DatePickerViewController(viewModel: viewModel, date: preDate)
		let bottomSheetVC = BottomSheetViewController(contentViewController: picker)
		picker.delegate = bottomSheetVC
		bottomSheetVC.modalPresentationStyle = .overFullScreen
		bottomSheetVC.setSetting(height: 360)
		self.present(bottomSheetVC, animated: false, completion: nil) // fasle(애니메이션 효과로 인해 부자연스럽움 제거)
	}
	
	/// Set Month Btn Text
	private func setMonth(_ date: Date) {
		if Date().getFormattedDate(format: "yyyy") != date.getFormattedDate(format: "yyyy") {
			monthButton.setTitle(date.getFormattedDate(format: "yyyy년 M월"), for: .normal)
		} else {
			monthButton.setTitle(date.getFormattedDate(format: "M월"), for: .normal)
		}
	}
	
	/// Push Home Filter VC
	private func didTapFilterButton() {
		let vc = HomeFilterViewController(viewModel: viewModel)
		vc.hidesBottomBarWhenPushed = true	// TabBar Above
		navigationController?.pushViewController(vc, animated: true)
	}
	
	/// 네트워크 오류시 스낵바 노출
	func showSnack() {
		let snackView = SnackView(viewModel: viewModel)
		snackView.setSnackAttribute()
		
		self.view.addSubview(snackView)
		
		snackView.snp.makeConstraints {
			$0.left.right.equalTo(view.safeAreaLayoutGuide).inset(24)
			$0.bottom.equalTo(view.snp.bottom).offset(-16 - (82+24)) // tabBar 높이 + Plus 버튼 윗부분
			$0.height.equalTo(40)
		}
		
		snackView.toastAnimation(duration: 1.0, delay: 3.0, option: .curveEaseOut)
	}
}
//MARK: - Style & Layouts
private extension HomeViewController {
	// 초기 셋업할 코드들
	private func setup() {
		bind()
		setAttribute()
		setLayout()
	}
	
	private func bind() {
		// MARK: input
		todayButton.tapPublisher
			.sinkOnMainThread(receiveValue: didTapTodayButton)
			.store(in: &cancellable)
		
		monthButton.tapPublisher
			.sinkOnMainThread(receiveValue: didTapMonthButton)
			.store(in: &cancellable)

		filterButton.tapPublisher
			.throttle(for: .seconds(1), scheduler: DispatchQueue.main, latest: false) // 처음에 구독한 시점에 value를 한번 바로 방출
			.sinkOnMainThread(receiveValue: didTapFilterButton)
			.store(in: &cancellable)
		
		// Fetch 재시도
		retryButton.tapPublisher
			.throttle(for: .seconds(2), scheduler: DispatchQueue.main, latest: false) // 처음에 구독한 시점에 value를 한번 바로 방출
			.sinkOnMainThread(receiveValue: {
				self.loadView.play()
				self.loadView.isPresent = true
				self.loadView.modalPresentationStyle = .overFullScreen
				self.present(self.loadView, animated: false)
				
				DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
					self.fetchData()
				}
			})
			.store(in: &cancellable)
		
		// MARK: output
		// 월별 데이터 표시
		viewModel.$monthlyList
			.sinkOnMainThread(receiveValue: { [weak self] monthly in
				self?.calendarHeaderView.setData(pay: monthly.reduce(0){$0 + $1.pay}, earn: monthly.reduce(0){$0 + $1.earn})
				self?.calendar.reloadData()
			}).store(in: &cancellable)

		// 일별 데이터 표시
		viewModel.$dailyList
			.sinkOnMainThread(receiveValue: { [weak self] daily in
				self?.tableView.reloadData()
			}).store(in: &cancellable)
				
		// Picker 날짜 표시
		viewModel.$date
			.sinkOnMainThread(receiveValue: { [weak self] date in
				self?.didSelectDate(date)
			}).store(in: &cancellable)

		// 월별과 일별을 합쳐 Loading 표시
		viewModel.isLoading
			.sinkOnMainThread(receiveValue: { [weak self] loading in
				guard let self = self else { return }
				
				if loading && !self.loadView.isPresent {
					self.loadView.play()
					self.loadView.isPresent = true
					self.loadView.modalPresentationStyle = .overFullScreen
					self.present(self.loadView, animated: false)
				} else {
					self.loadView.dismiss(animated: false)
				}
			}).store(in: &cancellable)
		
		// 월별 에러 표시
		viewModel.$errorMonthly
			.sinkOnMainThread(receiveValue: { [weak self] isError in
				guard let self = self, let isError = isError else { return }

				if isError {
					if !errorBgView.isHidden { return } // [중복 처리] 이미 에러 표시할 경우
					monthButton.isHidden = true			// Nav 왼쪽 노출
					righthStackView.isHidden = true		// Nav 오른쪽 노출
					calendar.scope = .month				// 월별
					
					errorBgView.isHidden = false
				} else {
					monthButton.isHidden = false		// Nav 왼쪽 숨김
					righthStackView.isHidden = false	// Nav 오른쪽 숨김
					
					errorBgView.isHidden = true
				}
			}).store(in: &cancellable)
		
		// 일별 에러 표시
		viewModel.$errorDaily
			.sinkOnMainThread(receiveValue: { [weak self] isError in
				guard let self = self, let isError = isError else { return }

				dailyErrorView.isHidden = !isError
			}).store(in: &cancellable)
		
		viewModel.isError
			.sinkOnMainThread(receiveValue: { [weak self] isError in
				guard let self = self else { return }
				
				if isError { showSnack() } // 네트워크 오류
			}).store(in: &cancellable)

//		viewModel
//			.transform(input: viewModel.input.eraseToAnyPublisher())
//			.sinkOnMainThread(receiveValue: { [weak self] state in
//				switch state {
//				case .errorMessage(_):
//					break
//				case .toggleButton(isEnabled: let isEnabled):
//					self?.toggleCheckButton(isEnabled)
//				}
//			}).store(in: &cancellables)
	}
	
	private func setAttribute() {
		// [view]
		view.backgroundColor = R.Color.gray100
		view.addGestureRecognizer(self.scopeGesture)
		
		if let navigationController = self.navigationController {
			if let rootVC = navigationController.viewControllers.first {
				rootVC.navigationItem.leftBarButtonItem = monthButtonItem
				rootVC.navigationItem.rightBarButtonItem = rightBarItem
			}
		}
		
        // tabbar
        tabBarViewModel.$isPlusButtonTappedInHome
            .receive(on: DispatchQueue.main)
            .sink {
                if $0 {
					let vc = AddViewController(parentVC: self)
                    self.navigationController?.pushViewController(vc, animated: true)
                    self.tabBarViewModel.isPlusButtonTappedInHome = false
                }
            }.store(in: &cancellable)
        
		monthButton = monthButton.then {
			$0.frame = .init(origin: .zero, size: .init(width: 150, height: 24))
			$0.setTitle(Date().getFormattedDate(format: "M월"), for: .normal)
			$0.setImage(R.Icon.arrowExpandMore16, for: .normal)
			$0.setTitleColor(R.Color.white, for: .normal)
			$0.setTitleColor(R.Color.white.withAlphaComponent(0.7), for: .highlighted)
			$0.imageView?.contentMode = .scaleAspectFit
			$0.titleLabel?.font = R.Font.h5
			$0.contentHorizontalAlignment = .left
			$0.imageEdgeInsets = .init(top: 0, left: 11, bottom: 0, right: 0) // 이미지 여백
		}
		
		monthButtonItem = monthButtonItem.then {
			$0.customView = monthButton
		}
		
		rightBarItem = rightBarItem.then {
			$0.customView = righthStackView
		}
		
		righthStackView = righthStackView.then {
			$0.distribution = .equalSpacing
			$0.axis = .horizontal
			$0.alignment = .center
			$0.spacing = 18.66
			$0.addArrangedSubviews(todayButton, filterButton)
		}
		
		todayButton = todayButton.then {
			$0.setTitle("오늘", for: .normal)
			$0.setTitleColor(R.Color.gray300, for: .normal)
			$0.setBackgroundColor(R.Color.gray800, for: .highlighted)
			$0.titleLabel?.font = R.Font.body3
			$0.layer.cornerRadius = 12
			$0.layer.borderWidth = 1
			$0.layer.borderColor = R.Color.gray800.cgColor
		}
		
		filterButton = filterButton.then {
			$0.setImage(R.Icon.setting, for: .normal)
		}
		
		separator = separator.then {
			$0.backgroundColor = R.Color.gray800
		}
		
		calendar = calendar.then {
			$0.backgroundColor = R.Color.gray900
			$0.scope = .month									// 한달 단위(기본값)로 보여주기
			$0.delegate = self
			$0.dataSource = self
			$0.select(Date())
			$0.today = Date()										// default 오늘 표시 제거
			$0.headerHeight = 8									// deafult header 제거
			$0.calendarHeaderView.isHidden = true				// deafult header 제거
			$0.placeholderType = .none							// 달에 유효하지않은 날짜 지우기
			$0.appearance.titleTodayColor = R.Color.white
			$0.appearance.titleDefaultColor = R.Color.gray300 	// 달력의 평일 날짜 색깔
			$0.appearance.titleFont = R.Font.body5				// 달력의 평일 글자 폰트
			$0.appearance.titlePlaceholderColor = R.Color.gray300.withAlphaComponent(0.5) // 달에 유효하지 않은 날짜의 색 지정
			$0.appearance.weekdayTextColor = R.Color.gray100	// 달력의 요일 글자 색깔
			$0.appearance.weekdayFont = R.Font.body5			// 달력의 요일 글자 폰트
			$0.appearance.headerMinimumDissolvedAlpha = 0		// 년월에 흐릿하게 보이는 애들 없애기
			$0.appearance.subtitleFont = R.Font.prtendard(size: 9)
			$0.appearance.subtitleDefaultColor = R.Color.gray300
			$0.appearance.subtitleOffset = CGPoint(x: 0, y: 12)	// 캘린더 숫자와 subtitle간의 간격 조정
			$0.register(CalendarCell.self, forCellReuseIdentifier: "CalendarCell")
		}
		
		scopeGesture = scopeGesture.then { 
			$0.addTarget(self.calendar, action: #selector(self.calendar.handleScopeGesture(_:)))
			$0.delegate = self
			$0.minimumNumberOfTouches = 1
			$0.maximumNumberOfTouches = 2
		}
		
		tableView = tableView.then {
			$0.delegate = self
			$0.dataSource = self
			$0.backgroundColor = R.Color.gray100
			$0.showsVerticalScrollIndicator = false
			$0.tableHeaderView = headerView
			$0.register(HomeTableViewCell.self)
			$0.panGestureRecognizer.require(toFail: self.scopeGesture)
			$0.separatorStyle = .none
		}
		
		headerView = headerView.then {
			$0.backgroundColor = R.Color.gray100
			$0.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 44)
		}

		dayLabel = dayLabel.then {
			$0.text = Date().getFormattedDate(format: "dd일 (EEEEE)") // 요일을 한글자로 표현
			$0.font = R.Font.title3
			$0.textColor = R.Color.gray900
			$0.textAlignment = .left
		}
		
		emptyView = emptyView.then {
			$0.isHidden = true
		}
		
		errorBgView = errorBgView.then {
			$0.backgroundColor = R.Color.gray100
			$0.isHidden = true
		}
		
		retryButton = retryButton.then {
			$0.setTitle("재시도하기", for: .normal)
			$0.titleLabel?.font = R.Font.prtendard(family: .medium, size: 18)
			$0.setBackgroundColor(R.Color.gray800, for: .normal)
			$0.layer.cornerRadius = 4
			$0.layer.shadowColor = UIColor.black.cgColor
			$0.layer.shadowOpacity = 0.25
			$0.layer.shadowOffset = CGSize(width: 0, height: 2)
			$0.layer.shadowRadius = 8
		}
		
		dailyErrorView = dailyErrorView.then {
			$0.isHidden = true
		}
	}
	
	private func setLayout() {
		headerView.addSubview(dayLabel)
		errorBgView.addSubviews(monthlyErrorView, retryButton)
		view.addSubviews(calendarHeaderView, calendar, separator, tableView, emptyView, dailyErrorView, errorBgView)

		todayButton.snp.makeConstraints {
			$0.width.equalTo(49)
			$0.height.equalTo(24)
		}
		
		separator.snp.makeConstraints {
			$0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(15)
			$0.top.equalTo(view.safeAreaLayoutGuide)
			$0.height.equalTo(1)
		}
		
		calendarHeaderView.snp.makeConstraints {
			$0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
			$0.height.equalTo(46)
		}
				
		calendar.snp.makeConstraints {
			$0.top.equalTo(calendarHeaderView.snp.bottom)
			$0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
			$0.height.equalTo(300) // 기기 대응 - UIScreen.height * 0.37
		}

		dayLabel.snp.makeConstraints {
			$0.top.equalToSuperview().inset(16)
			$0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
		}
		
		tableView.snp.makeConstraints {
			$0.bottom.leading.trailing.equalTo(view.safeAreaLayoutGuide)
			$0.top.equalTo(calendar.snp.bottom)
		}
		
		emptyView.snp.makeConstraints {
			$0.centerX.equalTo(tableView.snp.centerX)
			$0.centerY.equalTo(tableView.snp.centerY)
		}
		
		errorBgView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
		
		monthlyErrorView.snp.makeConstraints {
			$0.centerX.equalToSuperview()
			$0.centerY.equalToSuperview().offset(-40) // 재시도 버튼과의 거리
		}
		
		retryButton.snp.makeConstraints {
			$0.top.equalTo(monthlyErrorView.snp.bottom).offset(40)
			$0.left.right.equalToSuperview().inset(56)
			$0.height.equalTo(56)
		}
		
		dailyErrorView.snp.makeConstraints {
			$0.centerX.equalTo(tableView.snp.centerX)
			$0.centerY.equalTo(tableView.snp.centerY)
			$0.width.equalTo(tableView)
		}
	}
}
//MARK: - FSCalendar DataSource, Delegate
extension HomeViewController: FSCalendarDataSource, FSCalendarDelegate {
	// 셀 정의
	func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
		let cell = calendar.dequeueReusableCell(withIdentifier: "CalendarCell", for: date, at: position) as! CalendarCell
		
		if let index = viewModel.monthlyList.firstIndex(where: {$0.createAt == date.getFormattedYMD()}) {
			let price = viewModel.monthlyList[index].total
			switch price {
			case ..<0: // - 지출
				if viewModel.isHighlight { // 하이라이트가 켜져 있을 경우
					cell.setData(color: viewModel.payStandard <= -price ? R.Color.orange400 : R.Color.orange200)
				} else {
					cell.setData(color: R.Color.orange200)
				}
			case 1...: // + 수입
				if viewModel.isHighlight {
					cell.setData(color: viewModel.earnStandard <= price ? R.Color.blue400 : R.Color.blue200)
				} else {
					cell.setData(color: R.Color.blue200)
				}
			default: // 0
				cell.setData(color: R.Color.white)
			}
		}
		
		return cell
	}
	
	// 캘린더 선택
	func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
		guard preDate.getFormattedYMD() != date.getFormattedYMD() else { return } // 같은 날짜를 선택할 경우
		
		self.didSelectDate(date)
	}
	
	// subTitle (수익/지출)
	func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
		guard viewModel.isDailySetting else { return nil }
		
		if let index = viewModel.monthlyList.firstIndex(where: {$0.createAt == date.getFormattedYMD()}) {
			return viewModel.monthlyList[index].total.withCommasAndPlus(maxValue: 10_000_000) // 1000만원 이하로 제한
		}
		
		return ""
	}
		
	// 스크롤시, calendar 높이 조절
	func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
		calendar.snp.updateConstraints {
			$0.height.equalTo(bounds.height) // 높이 변경
		}
		// 46 : calendarHeaderView 높이
		// UIScreen.height * 0.37 : calendar 높이
		// 85 : calendar 주 단위 높이
		calendarHeaderView.snp.updateConstraints {
			$0.height.equalTo(46 * (bounds.height - 85) / (300 - 85)) // calendar 전체 높이에 따른 높이 변경
		}
		
		self.setMonth(calendar.currentPage) // 월 Text 변경
		self.view.layoutIfNeeded()
	}

	// page가 변경될때 month 변경
	func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
		let date = calendar.currentPage.getFormattedYM()
		
		if calendar.scope == .week { // 주 단위
			if let dateAfter = Calendar.current.date(byAdding: .day, value: 6, to: calendar.currentPage) { // 해당 주의 마지막 날짜
				if date != dateAfter.getFormattedYM() {
					viewModel.getWeeklyList(date, dateAfter.getFormattedYM())
				}
			}
		} else { // 월 단위
			viewModel.getMonthlyList(date)
		}
		self.setMonth(calendar.currentPage) // 월 설정
	}
}
//MARK: - FSCalendar Delegate Appearance
extension HomeViewController: FSCalendarDelegateAppearance {
	// 기본 cell title 색상
	func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
		if viewModel.monthlyList.contains(where: {$0.createAt == date.getFormattedYMD()}) {
			return R.Color.gray900
		} else if date.getFormattedYMD() == Date().getFormattedYMD() {
			return R.Color.white
		} else {
			return R.Color.gray300
		}
	}
	
	// 선택시, title 색상
	func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleSelectionColorFor date: Date) -> UIColor? {
		if viewModel.monthlyList.contains(where: {$0.createAt == date.getFormattedYMD()}) {
			return R.Color.gray900
		} else if date.getFormattedYMD() == Date().getFormattedYMD() {
			return R.Color.white
		} else {
			return R.Color.gray300
		}
	}
	
	// 기본 subtitle 색상
	func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, subtitleDefaultColorFor date: Date) -> UIColor? {
		return R.Color.gray300
	}
	
	// 선택시, subtitle 색상
	func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, subtitleSelectionColorFor date: Date) -> UIColor? {
		return R.Color.gray300
	}
}
//MARK: - UIGesture Recognizer Delegate
extension HomeViewController: UIGestureRecognizerDelegate {
	// 스크롤 제스쳐
	func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		let shouldBegin = self.tableView.contentOffset.y <= -self.tableView.contentInset.top
		if shouldBegin {
			let velocity = self.scopeGesture.velocity(in: self.view)
			switch self.calendar.scope {
			case .month:
				return velocity.y < 0
			case .week:
				return velocity.y > 0
			default:
				return false
			}
		}
		return shouldBegin
	}
}
//MARK: - UITableView DataSource
extension HomeViewController: UITableViewDataSource {

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		tableView.bounces = !viewModel.dailyList.isEmpty
		emptyView.isHidden = !viewModel.dailyList.isEmpty
		return viewModel.dailyList.count
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let padding: CGFloat = 24
		return viewModel.dailyList[indexPath.row].memo.isEmpty ? 42 + padding : 64 + padding
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.className, for: indexPath) as! HomeTableViewCell
		
		cell.setData(data: viewModel.dailyList[indexPath.row], last: indexPath.row == self.viewModel.dailyList.count - 1)
		cell.backgroundColor = R.Color.gray100
		
		let backgroundView = UIView()
		backgroundView.backgroundColor = R.Color.gray400.withAlphaComponent(0.3)
		cell.selectedBackgroundView = backgroundView

		return cell
	}
}
//MARK: - UITableView Delegate, UIScrollView Delegate
extension HomeViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		// 셀 터치시 회색 표시 없애기
		tableView.deselectRow(at: indexPath, animated: true)
        let vc = DetailViewController()
        let economicActivityId = viewModel.dailyList.map{ $0.id }
        let index = indexPath.row
        let date = preDate
        vc.setData(economicActivityId: economicActivityId, index: index, date: date)

        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
	}
}
