//
//  PushSettingDetailViewController.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/08/24.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import ReactorKit

final class PushSettingDetailViewController: BaseViewControllerWithNav, View {
    // MARK: - UI Components
    private lazy var mainLabel = UILabel()
    private lazy var detailTimeSettingView = DetailTimeSettingView()
    private lazy var weekCollecitonView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    // MARK: - Properties
//    private let  weekList = Observable.of(["일", "화", "수", "목", "금", "토", "월"])
    // TODO: - rx로 변경
    private let weekList = ["일", "월", "화", "수", "목", "금", "토"]
    private var selectedDays: [Bool] = []
    
    var reactor: PushSettingDetailReactor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind(reactor: reactor)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        // 뷰가 사라질 때 해당 저장정보를 기반으로 바로 noti로 쏴줌
        reactor.action.onNext(.viewWillDisappear)
    }
    
    func bind(reactor: PushSettingDetailReactor) {
        bindAction(_reactor: reactor)
        bindState(_reactor: reactor)
    }
}

// MARK: - bind
extension PushSettingDetailViewController {
    private func bindAction(_reactor: PushSettingDetailReactor) {
        
        // 최초 진입 시 시간 타이틀을 userdefault값으로 설정
        reactor.action.onNext(.viewAppear(Common.getCustomPushTime()))
        
        
        detailTimeSettingView.rx.tapGesture()
            .when(.recognized)
            .map { .didTapDetailTimeSettingView }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // UserDefault의 값을 감지(저장된 시간의 값 변화를 감지)
        NotificationCenter.default.rx.notification(UserDefaults.didChangeNotification)
            .map { .checkPushTime }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
    }
    
    private func bindState(_reactor: PushSettingDetailReactor) {
        reactor.state
            .filter { !$0.isViewAppear }
            .map { $0.isPresentTime }
            .distinctUntilChanged()
            .filter { $0 }
            .bind(onNext: presentBottomSheet)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.pushTime }
            .bind(onNext: setTime)
            .disposed(by: disposeBag)
    }
}

// MARK: - Actions
extension PushSettingDetailViewController {
    private func presentBottomSheet(_ isPresent: Bool) {
        let dateString = Common.getCustomPushTime()
        // FIXME: - 수정
        print("푸시 데이트 : \(dateString)")
        
        let date = Date()
        let todayDateFormatter = DateFormatter()
        todayDateFormatter.dateFormat = "yyyy-MM-dd "
        let todayDate = todayDateFormatter.string(from: date) + dateString
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm a"
//        dateFormatter.locale = Locale(identifier: "ko_KR")
//        dateFormatter.timeZone = TimeZone(abbreviation: "KST")

//        
//        
//        if let date = dateFormatter.date(from: str) {
//            print("Converted Date: \(date)")
//        } else {
//            print("Invalid date format")
//        }
        
        
        let vc = DateBottomSheetViewController(title: "시간 설정", type: .time, date: todayDate.toTime() ?? Date(), height: 360, mode: .date, sheetMode: .drag, isDark: false)
		vc.reactor = DateBottomSheetReactor(provider: reactor.provider)
        self.present(vc, animated: true)
    }
    
    private func setTime(_ time: String) {
        detailTimeSettingView.configure(Common.getCustomPushTime())
    }
}
//MARK: - Attribute & Hierarchy & Layouts & Bind
extension PushSettingDetailViewController {
    override func setAttribute() {
        view.backgroundColor = R.Color.gray100
        title = "알람 시간 지정"
        view.addSubviews(mainLabel, detailTimeSettingView, weekCollecitonView)
        
        detailTimeSettingView = detailTimeSettingView.then {
            $0.layer.cornerRadius = 4
        }
        
        mainLabel = mainLabel.then {
            $0.text = "경제활동에 유용한 알림 받을 시간을 설정해주세요!"
            $0.font = R.Font.title1
            $0.textColor = R.Color.gray900
            $0.numberOfLines = 0
        }
        
        weekCollecitonView = weekCollecitonView.then {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            $0.collectionViewLayout = layout
            $0.backgroundColor = R.Color.gray900
            $0.delegate = self
            $0.dataSource = self
            $0.register(WeekCollectionViewCell.self, forCellWithReuseIdentifier: "WeekCollectionViewCell")
            $0.register(WeekCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "WeekCollectionHeaderView")
            // 내부의 레이아웃의 padding을 주는 방법
            $0.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
            $0.layer.cornerRadius = 4
            $0.isScrollEnabled = false
            $0.allowsMultipleSelection = true
        }
        
        // TODO: - 로직 위치 변경, 초기 설정은 모두 true
        selectedDays = Common.getCustomPushWeekList()
        
        // userDefault의 값을 기준으로 현재 cell들의 선택 유무를 결정하는 코드
        for (offset, day) in selectedDays.enumerated() {
            if day {
                var initialIndexPath = IndexPath(item: offset, section: 0)
                weekCollecitonView.selectItem(at: initialIndexPath, animated: false, scrollPosition: [])
            }
        }
    }
    
	override func setLayout() {
        mainLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
        }
        
        detailTimeSettingView.snp.makeConstraints {
            $0.top.equalTo(mainLabel.snp.bottom).offset(16)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
        }
        
        weekCollecitonView.snp.makeConstraints {
            $0.top.equalTo(detailTimeSettingView.snp.bottom).offset(8)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
            $0.height.equalTo(102)
        }
    }
}

// MARK: - CollectionView delegate
extension PushSettingDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let cell = collectionView.cellForItem(at: indexPath) as? WeekCollectionViewCell {
            selectedDays[indexPath.item].toggle()
            cell.setSelectedItem(selectedDays[indexPath.item])

        }
        Common.setCustomPushWeekList(selectedDays)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? WeekCollectionViewCell {
            selectedDays[indexPath.item].toggle()
            cell.setSelectedItem(selectedDays[indexPath.item])
        }
        Common.setCustomPushWeekList(selectedDays)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        // 이미 선택된 셀이 있는지 확인
        if let selectedItems = collectionView.indexPathsForSelectedItems, selectedItems.count == 1 {
            // 이미 하나의 셀이 선택된 경우, 다른 셀의 선택을 막음
            return false
        }
        return true
    }
}

// MARK: - CollectionView DataSource
extension PushSettingDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weekList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeekCollectionViewCell", for: indexPath) as? WeekCollectionViewCell else { return UICollectionViewCell() }
        
        // cell을 원형으로 만드는 코드
        cell.layer.cornerRadius = cell.frame.size.width / 2
        cell.clipsToBounds = true
        
        cell.isSelected = selectedDays[indexPath.item]
        
        // cell의 text를 정하는 코드 & on/off
        cell.configure(text: weekList[indexPath.row], isSelected: selectedDays[indexPath.item])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        // header
        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = collectionView
                .dequeueReusableSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: "WeekCollectionHeaderView",
                    for: indexPath) as? WeekCollectionHeaderView else { return WeekCollectionHeaderView() }
            return header
        } else { // footer
            guard let footer = collectionView
                .dequeueReusableSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionFooter,
                    withReuseIdentifier: "WeekCollectionHeaderView",
                    for: indexPath) as? WeekCollectionHeaderView else { return UICollectionReusableView() }
            
            return footer
        }
    }
    
    // Header 사이즈에 대한 정의
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.size.width, height: 26)
    }
    
    // header와 cell 간격 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
    }
    
}

// MARK: - CollectionView FlowLayout
extension PushSettingDetailViewController: UICollectionViewDelegateFlowLayout {
    // layout간 간격 정의
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    // cell간 간격 정의
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 6
    }
    
    // dummy cell을 이용한 cell 높이 동적 구현
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let padding: CGFloat = 16+16+(12*6)
        // 16 - 양 옆 padding
        // 12 - cell 간 padding
        let width = (collectionView.frame.width - padding) / 7
        
        return CGSize(width: width, height: width)
    }
}
