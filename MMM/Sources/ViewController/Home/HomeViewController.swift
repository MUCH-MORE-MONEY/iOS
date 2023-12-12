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
import UserNotifications
import RxSwift

final class HomeViewController: UIViewController {
	// MARK: - Properties
	private lazy var cancellable: Set<AnyCancellable> = .init()
	private let viewModel = HomeViewModel()
    var disposeBag = DisposeBag()
    
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
	private lazy var snackView = SnackView(viewModel: viewModel)
    // Nudge Properties
    private enum nudgeMessage {
        static let title = "💸 가계부 작성, 잊지 않도록 알려드려요!"
        static let content = "원하는 시간대에 알림 받고\n꾸준히 자산을 관리하는 습관을 만들어 보세요"
        static let confirm = "알림 설정"
        static let cancel = "닫기"
    }
    
    
	override func viewDidLoad() {
		super.viewDidLoad()
		setup()		// 초기 셋업할 코드들
//        viewModel.showTrackingPermissionAlert()
        
        // nudge test
//        Common.setSaveButtonTapped(false)
//        Common.setCustomPushNudge(false)
//        Common.setNudgeIfPushRestricted(false)
//        
//        print("getSaveButtonTapped : \(Common.getSaveButtonTapped())")
//        print("getCustomPuhsNudge : \(Common.getCustomPuhsNudge())")
//        print("getNudgeIfPushRestricted : \(Common.getNudgeIfPushRestricted())")
//        

        
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
        
        // nudge action
        checkNudgeAction()
        
		// FIXME: - 네비게이션 아이템 노출 우류
		if let navigationController = self.navigationController {
			if let rootVC = navigationController.viewControllers.first {
				rootVC.navigationItem.leftBarButtonItem = monthButtonItem
				rootVC.navigationItem.rightBarButtonItem = rightBarItem
			}
		}
		
		fetchData()
	}
	
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
            self.viewModel.requestTrackingAuthorization()
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
		self.viewModel.getDailyList(date.getFormattedYMD())
		self.viewModel.getWeeklyList(date.getFormattedYMD())
		self.setMonth(date)
		self.viewModel.preDate = date
	}
	
	// MARK: - Private
	/// 데이터 얻기
	private func fetchData() {
		// 3초뒤 변경
		DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
			self.viewModel.isWillAppear = true // viewWillAppear 일 경우에만 Loading 표시
			if self.calendar.scope == .month { // 월 단위
				self.viewModel.getMonthlyList(self.calendar.currentPage.getFormattedYM())
			} else { // 주 단위
				if let dateAfter = Calendar.current.date(byAdding: .day, value: 6, to: self.calendar.currentPage) { // 해당 주의 마지막 날짜
					let date = self.calendar.currentPage.getFormattedYM()
					if date != dateAfter.getFormattedYM() { // 마지막 날짜 비교
						self.viewModel.getWeeklyList(date, dateAfter.getFormattedYM())
					}
				}
			}
			// 위젯
			self.viewModel.getDailyList(Date().getFormattedYMD(), isWidget: true)
			self.viewModel.getWeeklyList(Date().getFormattedYMD())
			self.viewModel.isWillAppear = false
			
			self.viewModel.getDailyList(self.viewModel.preDate.getFormattedYMD())
		} 
	}
	
	/// 달력 Picker Bottom Sheet
	private func didTapMonthButton() {
		let picker = DatePickerViewController(viewModel: viewModel, date: viewModel.preDate)
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
		self.snackView.alpha = 1.0
		
		UIView.animate(withDuration: 1.0, delay: 3.0, options: [.curveEaseInOut, .allowUserInteraction]) {
			self.snackView.alpha = 0.0
		}
	}
    
    private func checkNudgeAction() {
        // nudge
        // 최초한번 눌렀을 경우 && 넛징이 아직 표시안된경우
        
        if Common.getSaveButtonTapped() && !Common.getCustomPuhsNudge() {
            
            Common.setCustomPushNudge(true)
            
            showAlert(alertType: .canCancel,
                      titleText: nudgeMessage.title,
                      contentText: nudgeMessage.content,
                      cancelButtonText: nudgeMessage.cancel,
                      confirmButtonText: nudgeMessage.confirm)
//                    
        }
        
        // test용 alert
//            showAlert(alertType: .canCancel,
//                      titleText: nudgeMessage.title,
//                      contentText: nudgeMessage.content,
//                      cancelButtonText: nudgeMessage.cancel,
//                      confirmButtonText: nudgeMessage.confirm)
    }
}
//MARK: - Attribute & Hierarchy & Layouts
private extension HomeViewController {
	// 초기 셋업할 코드들
	private func setup() {
		bind()
		setAttribute()
		setLayout()
	}
	
	private func bind() {
        // Foreground 상태 감지(알람 설정은 밖에서 하기 때문에)
        // 귀찮아서 그냥 rxswift 써버림 -> 나중에 바꿔야함 23/12/11 - pjw
        NotificationCenter.default.rx.notification(UIApplication.willEnterForegroundNotification)
            .filter { _ in Common.getSaveButtonTapped() && Common.getCustomPuhsNudge() && !Common.getNudgeIfPushRestricted() }
            .bind { [weak self] _ in
                guard let self = self else { return }
                // 밖에서 나갔다가 왔을 경우 현재 알람을 on/off 상태 판단해야함
                UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
                    // 알람창 갔다 왔을 때 알람을 키고 온 경우 요일설정 페이지 전환
                    if settings.authorizationStatus == .authorized {
                        DispatchQueue.main.async {
                            self?.moveToPushSettingDetailViewController()
                            Common.setNudgeIfPushRestricted(true)
                        }
                    } else {
                        print("이놈은 끝까지 푸시 설정 안하네")
                        Common.setNudgeIfPushRestricted(true)
                    }
                }
                print("밖에 나갔다가 들어옴")
                
            }
            .disposed(by: disposeBag)
        
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
					
					// 로딩이 끝나고, Snack Message 처리
					if viewModel.errorMonthly == false && viewModel.errorDaily == true {
						// 에러 Snack Message 띄우기
						showSnack()
					}
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
	}
	
	private func setAttribute() {
		// 토큰 출력
		if let token = Constants.getKeychainValue(forKey: Constants.KeychainKey.token) {
			print(#file, "Header Token : \(token)")
		}
		
		// [view]
		view.backgroundColor = R.Color.gray900
		view.addGestureRecognizer(self.scopeGesture)
        
		let view = UIView(frame: .init(origin: .zero, size: .init(width: 150, height: 30)))
		monthButton = monthButton.then {
			$0.frame = .init(origin: .init(x: 8, y: 0), size: .init(width: 150, height: 30))
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
		
		let rightView = UIView(frame: .init(origin: .zero, size: .init(width: 92, height: 30)))
		righthStackView = righthStackView.then {
			$0.axis = .horizontal
			$0.spacing = 16
			$0.addArrangedSubviews(todayButton, filterButton)
		}
		rightView.addSubview(righthStackView)
		
		rightBarItem = rightBarItem.then {
			$0.customView = rightView
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
		
		snackView = snackView.then {
			$0.setSnackAttribute()
			$0.alpha = 0.0
		}
	}
	
	private func setLayout() {
		headerView.addSubview(dayLabel)
		errorBgView.addSubviews(monthlyErrorView, retryButton)
		view.addSubviews(calendarHeaderView, calendar, separator, tableView, emptyView, dailyErrorView, errorBgView, snackView)

		todayButton.snp.makeConstraints {
			$0.width.equalTo(49)
			$0.height.equalTo(24)
		}
		
		righthStackView.snp.makeConstraints {
			$0.width.equalTo(90)
		}
		
		separator.snp.makeConstraints {
			$0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(15)
			$0.top.equalTo(view.safeAreaLayoutGuide)
			$0.height.equalTo(1)
		}
		
		calendarHeaderView.snp.makeConstraints {
			$0.top.equalTo(view.safeAreaLayoutGuide)
			$0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(8)
			$0.height.equalTo(46)
		}
				
		calendar.snp.makeConstraints {
			$0.top.equalTo(calendarHeaderView.snp.bottom)
			$0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(8)
			$0.height.equalTo(300) // 기기 대응 - UIScreen.height * 0.37
		}

		dayLabel.snp.makeConstraints {
			$0.top.equalToSuperview().inset(16)
			$0.leading.equalToSuperview().inset(24)
		}
		
		tableView.snp.makeConstraints {
			$0.leading.trailing.equalToSuperview()
			$0.bottom.equalTo(view.safeAreaLayoutGuide)
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
				
		snackView.snp.makeConstraints {
			$0.leading.trailing.equalToSuperview().inset(24)
			$0.bottom.equalTo(view.snp.bottom).offset(-24) // Plus 버튼 윗부분과의 거리
			$0.height.equalTo(40)
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
		guard viewModel.preDate.getFormattedYMD() != date.getFormattedYMD() else { return } // 같은 날짜를 선택할 경우
		
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
		return UITableView.automaticDimension
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
        let index = indexPath.row
        let vc = DetailViewController(homeViewModel: viewModel, index: index)
        let economicActivityId = viewModel.dailyList.map{ $0.id }

		let date = viewModel.preDate
        vc.setData(economicActivityId: economicActivityId, index: index, date: date)

        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
	}
}

extension HomeViewController: CustomAlertDelegate {
    func didAlertCofirmButton() {
        print("confirm")
//        let vc = PushSettingDetailViewController()
//        vc.reactor = PushSettingDetailReactor(provider: ServiceProvider.shared)
//        
//        navigationController?.pushViewController(vc, animated: true)
        
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            guard let self = self else { return }
            if settings.authorizationStatus == .authorized {
                // 권한 있을 경우
                DispatchQueue.main.async {
                    self.moveToPushSettingDetailViewController()
                }

            } else { // 권한이 없을 경우 setting 앱으로 이동 -> 딥링크
                
                // 16 이상 부터 알림 설정 딥링크 이동 가능
                if #available(iOS 16.0, *) {
                    DispatchQueue.main.async {
                        if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        } else {
                            print("이동 실패")
                        } // 딥링크 이동 실패
                    }
                    
                    
                } else { // 16미만 버전은 앱 설정 까지만 이동 가능
                    DispatchQueue.main.async {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        } else {
                            print("이동 실패")
                        } // 딥링크 이동 실패
                    }
                }
//                self.showAlertToRedirectToSettings()
            }
        }
    }
    
    func didAlertCacelButton() {
//        print("cancel")
//        Common.setCustomPushNudge(false)
    }
    
    func handleTap() {
//        print("handle tap")
//        Common.setCustomPushNudge(false)
    }
    
    func moveToPushSettingDetailViewController() {
        let vc = PushSettingDetailViewController()
        vc.reactor = PushSettingDetailReactor(provider: ServiceProvider.shared)

        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showAlertToRedirectToSettings() {
        let alertController = UIAlertController(
            title: "‘MMM’에서 알림을 보내고자 합니다.",
            message: "경고, 사운드 및 아이콘 배지가 알림에 포함될 수 있습니다. 설정에서 이를 구성할 수 있습니다.",
            preferredStyle: .alert
        )

        let settingsAction = UIAlertAction(title: "허용", style: .default) { [weak self] (_) in
            // 권한 허용 후 vc 이동
            guard let self = self else { return }
            if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
//            self.moveToPushSettingDetailViewController()
        }

        let cancelAction = UIAlertAction(title: "허용 안함", style: .cancel, handler: nil)
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)

        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
