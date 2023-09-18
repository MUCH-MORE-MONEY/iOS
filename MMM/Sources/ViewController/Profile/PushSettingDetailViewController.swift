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
    private let weekList = ["일", "화", "수", "목", "금", "토", "월"]
    var disposeBag: DisposeBag = DisposeBag()
    var reactor: PushSettingDetailReactor!
    var bottomSheetReactor: BottomSheetReactor = BottomSheetReactor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bind(reactor: reactor)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        
    }
    
    func bind(reactor: PushSettingDetailReactor) {
        bindAction(_reactor: reactor)
        bindState(_reactor: reactor)
    }
}

// MARK: - bind
extension PushSettingDetailViewController {
    private func bindAction(_reactor: PushSettingDetailReactor) {
        detailTimeSettingView.rx.tapGesture()
            .when(.recognized)
            .map { _ in .didTapDetailTimeSettingView }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(_reactor: PushSettingDetailReactor) {
        reactor.state
            .map { $0.isPresentTime }
            .distinctUntilChanged()
            .filter { $0 }
            .bind(onNext: presentBottomSheet)
            .disposed(by: disposeBag)
        
        bottomSheetReactor.state
            .map { $0.success }
            .distinctUntilChanged()
            .bind(onNext: setTime)
            .disposed(by: disposeBag)
    }
}

// MARK: - Actions
extension PushSettingDetailViewController {
    private func presentBottomSheet(_ isPresent: Bool) {
        let vc = DatePicker2ViewController()
        let bottomSheetVC = BottomSheetViewController(contentViewController: vc)
        vc.reactor = bottomSheetReactor
        vc.delegate = bottomSheetVC
        vc.setData(title: "시간 설정", type: .time)
        bottomSheetVC.modalPresentationStyle = .overFullScreen
        bottomSheetVC.setSetting(height: 360)
        self.present(bottomSheetVC, animated: false)
    }
    
    private func setTime(_ date: Date) {
        detailTimeSettingView.configure(date)
    }
}

extension PushSettingDetailViewController {
    private func setup() {
        setAttribute()
        setLayout()
    }
    
    private func setAttribute() {
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
        }
    }
    
    private func setLayout() {
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
//            $0.height.equalTo(mainImageView.image!.size.height * view.frame.width / mainImageView.image!.size.width)
        }
    }
}

// MARK: - CollectionView delegate
extension PushSettingDetailViewController: UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        <#code#>
//    }
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
        
        cell.backgroundColor = .lightGray
        
        cell.configure(weekList[indexPath.row])
        
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
        
//        let width = view.frame.width
//        let estimatedHeight: CGFloat = 300.0 // 높이가 300 이상이 되지 않을 것이라고 가정
//        let dummyCell = WeekCollectionViewCell(frame: CGRect(x: 0, y: 0, width: width, height: estimatedHeight))
        
        let width = collectionView.frame.width / 7

        let size = CGSize(width: 32, height: 32)
        
        return size
    }
    
}
