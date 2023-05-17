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

protocol HomeViewProtocol: AnyObject {
	func willPickerDismiss(_ date: Date)
}

class HomeViewController: UIViewController {
	// MARK: - Properties
	private lazy var cancellable: Set<AnyCancellable> = .init()
	private let viewModel = HomeViewModel()
	private lazy var preDate = Date() // yyyyMMdd
	
	// MARK: - UI Components
	private lazy var monthButtonItem = UIBarButtonItem()
	private lazy var todayButtonItem = UIBarButtonItem()
	private lazy var monthButton = UIButton()
	private lazy var todayButton = UIButton()
	private lazy var settingButton = UIBarButtonItem()
	private lazy var separator = UIView() // Nav separator
	private lazy var calendar = FSCalendar()
	private lazy var calendarHeaderView = HomeHeaderView()
	private lazy var emptyView = HomeEmptyView()
	private lazy var tableView = UITableView()
	private lazy var headerView = UIView()
	private lazy var dayLabel = UILabel()
	private lazy var scopeGesture = UIPanGestureRecognizer()
		
	public init() {
		super.init(nibName: nil, bundle: nil)
	}
	
	// Compile time에 error를 발생시키는 코드
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setup()		// 초기 셋업할 코드들
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		tableView.reloadData()
//		self.navigationController?.setNavigationBarHidden(true, animated: animated)	// navigation bar 숨김
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.navigationController?.setNavigationBarHidden(false, animated: animated) // navigation bar 노출
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent // status text color 변경
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
	}
	
	// 달력 Picker BottomSheet
	func didTapMonthButton() {
		let picker = DatePickerViewController()
		let bottomSheetVC = BottomSheetViewController(contentViewController: picker)
		picker.delegate = bottomSheetVC
		picker.homeDelegate = self
		bottomSheetVC.modalPresentationStyle = .overFullScreen
		bottomSheetVC.setSetting(height: 375)
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
}

//MARK: - Style & Layouts
extension HomeViewController {
	private func setup() {
		// 초기 셋업할 코드들
		bind()
		setAttribute()
		setLayout()
	}
	
	private func bind() {
		//MARK: input
		todayButton.tapPublisher
			.sinkOnMainThread(receiveValue: didTapTodayButton)
			.store(in: &cancellable)
		
		monthButton.tapPublisher
			.sinkOnMainThread(receiveValue: didTapMonthButton)
			.store(in: &cancellable)
//		checkButton.tapPublisher
//			.receive(on: DispatchQueue.main)
//			.sinkOnMainThread(receiveValue: go)
//			.store(in: &cancellables)
		
		// 예시
//		UITextField().textPublisher
//			.receive(on: DispatchQueue.main)
//			.assign(to: \.passwordInput, on: viewModel)
//			.store(in: &cancellables)
		
		//MARK: output
		viewModel.$dailyList
			.sinkOnMainThread(receiveValue: { [weak self] daily in
				self?.tableView.reloadData()
			})
			.store(in: &self.cancellable)
		
		viewModel.$monthlyList
			.sinkOnMainThread(receiveValue: { [weak self] monthly in
				self?.calendarHeaderView.setUp(pay: monthly.reduce(0){$0 + $1.pay}, earn: monthly.reduce(0){$0 + $1.earn})
				self?.calendar.reloadData()
			})
			.store(in: &self.cancellable)
		
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
		
//		viewModel.isMatchPasswordInput
//			.receive(on: DispatchQueue.main)
//			.sink(receiveValue: go2)
//			.store(in: &cancellables)
	}
	
	private func setAttribute() {
		// [view]
		view.backgroundColor = R.Color.gray100
		view.addGestureRecognizer(self.scopeGesture)
		navigationItem.leftBarButtonItem = monthButtonItem
		navigationItem.rightBarButtonItems = [settingButton, todayButtonItem]

		monthButton = monthButton.then {
			$0.frame = .init(origin: .zero, size: .init(width: 150, height: 24))
			$0.setTitle(Date().getFormattedDate(format: "M월"), for: .normal)
			$0.setImage(R.Icon.arrowExpandMore16, for: .normal)
			$0.setTitleColor(R.Color.white, for: .normal)
			$0.setTitleColor(R.Color.white.withAlphaComponent(0.7), for: .highlighted)
			$0.imageView?.contentMode = .scaleAspectFit
			$0.titleLabel?.font = R.Font.h5
			$0.contentHorizontalAlignment = .left
			$0.semanticContentAttribute = .forceRightToLeft //<- 중요
			$0.imageEdgeInsets = .init(top: 0, left: 11, bottom: 0, right: 0) // 이미지 여백
		}
		
		monthButtonItem = monthButtonItem.then {
			$0.customView = monthButton
		}
		
		todayButton = todayButton.then {
			$0.frame = .init(origin: .zero, size: .init(width: 49, height: 24))
			$0.setTitle("오늘", for: .normal)
			$0.setTitleColor(R.Color.gray300, for: .normal)
			$0.setBackgroundColor(R.Color.gray800, for: .highlighted)
			$0.titleLabel?.font = R.Font.body3
			$0.layer.cornerRadius = 12
			$0.layer.borderWidth = 2
			$0.layer.borderColor = R.Color.gray800.cgColor
		}
		
		todayButtonItem = todayButtonItem.then {
			$0.customView = todayButton
		}
		
		settingButton = settingButton.then {
			$0.image = R.Icon.setting
			$0.style = .plain
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
			$0.appearance.titleOffset = .init(x: 0, y: 8)
			$0.appearance.titlePlaceholderColor = R.Color.gray300.withAlphaComponent(0.5) // 달에 유효하지 않은 날짜의 색 지정
			$0.appearance.weekdayTextColor = R.Color.gray100	// 달력의 요일 글자 색깔
			$0.appearance.weekdayFont = R.Font.body5			// 달력의 요일 글자 폰트
			$0.appearance.headerMinimumDissolvedAlpha = 0		// 년월에 흐릿하게 보이는 애들 없애기
			$0.appearance.subtitleFont = R.Font.prtendard(size: 9)
			$0.appearance.subtitleDefaultColor = R.Color.gray300
			$0.appearance.subtitleOffset = CGPoint(x: 0, y: 22)	// 캘린더 숫자와 subtitle간의 간격 조정
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
			$0.separatorInset.left = 20
			$0.separatorInset.right = 20
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
		
		headerView.addSubview(dayLabel)
		view.addSubviews(calendarHeaderView, calendar, separator, tableView, emptyView)
	}
	
	private func setLayout() {
		separator.snp.makeConstraints {
			$0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(15)
			$0.top.equalTo(view.safeAreaLayoutGuide)
			$0.height.equalTo(1)
		}
		
		calendarHeaderView.snp.makeConstraints {
			$0.top.left.right.equalTo(view.safeAreaLayoutGuide)
			$0.height.equalTo(46)
		}
				
		calendar.snp.makeConstraints {
			$0.top.equalTo(calendarHeaderView.snp.bottom)
			$0.left.right.equalTo(view.safeAreaLayoutGuide)
			$0.height.equalTo(300)
		}

		dayLabel.snp.makeConstraints {
			$0.top.equalToSuperview().inset(16)
			$0.left.right.equalTo(view.safeAreaLayoutGuide).inset(20)
		}
		
		tableView.snp.makeConstraints {
			$0.bottom.left.right.equalTo(view.safeAreaLayoutGuide)
			$0.top.equalTo(calendar.snp.bottom)
		}
		
		emptyView.snp.makeConstraints {
			$0.centerX.equalTo(tableView.snp.centerX)
			$0.centerY.equalTo(tableView.snp.centerY)
		}
	}
}

//MARK: - FSCalendar DataSource, Delegate
extension HomeViewController: FSCalendarDataSource, FSCalendarDelegate {
	// 셀 정의
	func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
		let cell = calendar.dequeueReusableCell(withIdentifier: "CalendarCell", for: date, at: position) as! CalendarCell
		
		if viewModel.monthlyList.contains(where: {$0.createAt == date.getFormattedYMD()}) {
			cell.setUp(color: R.Color.orange200)
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
		if let index = viewModel.monthlyList.firstIndex(where: {$0.createAt == date.getFormattedYMD()}) {
			return viewModel.monthlyList[index].total.withCommasAndPlus()
		}
		
		return ""
	}
	
	// 스크롤시, calendar 높이 조절
	func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
		calendar.snp.updateConstraints {
			$0.height.equalTo(bounds.height) // 높이 변경
		}
		
		calendarHeaderView.snp.updateConstraints {
			$0.height.equalTo(bounds.height <= 300 / 2 ? 0 : 46) // calendar 전체 높이에 따른 높이 변경
		}
		
		self.view.layoutIfNeeded()
	}

	// page가 변경될때 month 변경
	func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
		viewModel.getMonthlyList(calendar.currentPage.getFormattedYM())

//		calendar.snp.updateConstraints {
//			$0.height.equalTo(350)
//		}
//		calendar.adjustsBoundingRectWhenChangingMonths = true
		
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
		
		cell.setUp(data: viewModel.dailyList[indexPath.row])
		cell.backgroundColor = R.Color.gray100

		if indexPath.row == viewModel.dailyList.count - 1 {
			// 마지막 cell은 bottom border 제거
			DispatchQueue.main.async {
				cell.addAboveTheBottomBorderWithColor(color: R.Color.gray100)
			}
		}
		
		return cell
	}
}
//MARK: - UITableView Delegate, UIScrollView Delegate
extension HomeViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		// 셀 터치시 회색 표시 없애기
		tableView.deselectRow(at: indexPath, animated: true)
	}
}

extension HomeViewController: HomeViewProtocol {
	
	func willPickerDismiss(_ date: Date) {
		self.didSelectDate(date)
	}
}
