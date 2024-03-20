//
//  DetailViewController2.swift
//  MMM
//
//  Created by yuraMacBookPro on 12/21/23.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa
import Lottie
import ReactorKit

final class DetailViewController2: BaseDetailViewController, UIScrollViewDelegate, View {
    typealias Reactor = DetailReactor
    
    // MARK: - UI Components
    private lazy var starStackView = UIStackView()
    private lazy var editActivityButtonItem = UIBarButtonItem()
    private lazy var editButton = UIButton()
    private lazy var titleLabel = UILabel()
    private lazy var scrollView = UIScrollView()
    private lazy var contentView = UIView()
    private lazy var satisfactionLabel = BasePaddingLabel(padding: UIEdgeInsets(top: 3, left: 12, bottom: 3, right: 12))
    private lazy var mainImageView = UIImageView()
    private lazy var cameraImageView = CameraImageView()
    private lazy var bottomPageControlView = BottomPageControlView2()
    private lazy var memoLabel = UILabel()
    private lazy var starList: [UIImageView] = [
        UIImageView(image: R.Icon.iconStarDisabled16),
        UIImageView(image: R.Icon.iconStarDisabled16),
        UIImageView(image: R.Icon.iconStarDisabled16),
        UIImageView(image: R.Icon.iconStarDisabled16),
        UIImageView(image: R.Icon.iconStarDisabled16)
    ]
    lazy var addCategoryView = AddCategoryView()
    private lazy var addScheduleTapView = AddScheduleTapView()
    private lazy var separatorView = SeparatorView()
    
    // MARK: - LoadingView
    private lazy var loadingView = LoadingViewController()
    
    // MARK: - Properties
    private var hasImage = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let reactor = self.reactor else { return }
        
        let dateYM = reactor.currentState.dateYM
        let rowNum = reactor.currentState.rowNum
        let valueScoreDvcd = reactor.currentState.valueScoreDvcd
        let id = reactor.currentState.id
        
        reactor.action.onNext(.loadData(dateYM: dateYM, rowNum: rowNum, valueScoreDvcd: valueScoreDvcd, id: id))
    }
    
    func bind(reactor: DetailReactor) {
        bindAction(reactor)
        bindState(reactor)
    }
}

// MARK: - Bind
extension DetailViewController2 {
    private func bindAction(_ reactor: DetailReactor) {
        editButton.rx.tap
            .map {.didTapEditButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // 최종 손가락 위치 오른쪽
        view.rx.swipeGesture(.left)
            .when(.recognized)
            .filter{ _ in self.bottomPageControlView.index < self.bottomPageControlView.totalItem }
            .map { .didTapNextButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // 최종 손가락 위치 왼쪽
        view.rx.swipeGesture(.right)
            .when(.recognized)
            .filter{ _ in self.bottomPageControlView.index > 1 }
            .map { .didTapPreviousButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(_ reactor: DetailReactor) {
        reactor.state
            .map { $0.isPushEditVC }
            .distinctUntilChanged()
            .filter { $0 }
            .bind(onNext: pushEditVC)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.editActivity }
            .distinctUntilChanged()
            .bind(onNext: updateUI)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isLoading }
            .distinctUntilChanged()
            .bind(onNext: showLoadingView)
            .disposed(by: disposeBag)
    }
}


// MARK: - Action
private extension DetailViewController2 {
    func pushEditVC(_ isPush: Bool) {
        // FIXME: - Editactivity도 reactor로 바꿔야함
        let detailVM = HomeDetailViewModel()
        let editVM = EditActivityViewModel(isAddModel: false)
        
        guard let reactor = reactor else { return }
        guard let activity = reactor.currentState.editActivity else { return }
        
        detailVM.detailActivity = activity
        
        detailVM.hasImage = self.hasImage

        if cameraImageView.isHidden {
            let mainImage = mainImageView.image
            detailVM.mainImage = mainImage
        } else {
            detailVM.mainImage = nil
        }
        
        let vc = EditActivityViewController(detailViewModel: detailVM, editViewModel: editVM, date: Date())
        
        // 24.02.02 reactorkit으로 변경중 잠깐 스톱함
//        let vc = EditActivityViewController2()
//        vc.reactor = EditActivityReactor(activity: activity)
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func updateUI(_ activity: SelectDetailResDto) {


        let originalString = activity.createAt

        // 원본 문자열을 날짜로 변환하기 위한 DateFormatter 설정
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd" // 원본 문자열의 형식

        // 문자열을 Date로 변환
        if let date = dateFormatter.date(from: originalString) {
            // 새로운 형식으로 문자열을 변환하기 위한 DateFormatter 설정
            dateFormatter.dateFormat = "MM월 dd일"
            let newString = dateFormatter.string(from: date) + " 경제활동"
            self.title = newString
//            print(newString) // 결과: "11월 10일 경제활동"
        } else {
            print("날짜 변환 실패")
        }
        
        self.titleLabel.text = activity.title
        self.activityType.text = activity.type == "01" ? "지출" : "수입"
        self.activityType.backgroundColor = activity.type == "01" ? R.Color.orange500 : R.Color.blue500
        self.starList.forEach {
            $0.image = R.Icon.iconStarGray16
        }
        
        for i in 0..<activity.star {
            self.starList[i].image = R.Icon.iconStarBlack16
        }
        
        if URL(string: activity.imageUrl) != nil {
            self.mainImageView.isHidden = false
            self.cameraImageView.isHidden = true
            self.mainImageView.setImage(urlStr: activity.imageUrl, defaultImage: R.Icon.camera48)
            self.remakeConstraintsByMainImageView()
            self.hasImage = true
        } else {
            self.mainImageView.isHidden = true
            self.cameraImageView.isHidden = false
            self.remakeConstraintsByCameraImageView()
            self.hasImage = false
        }
        
        
        self.totalPrice.text = "\(activity.amount.withCommas())원"
        if !activity.memo.isEmpty {
            self.memoLabel.text = activity.memo
            memoLabel.textColor = R.Color.black
        } else {
            memoLabel.textColor = R.Color.gray400
            self.memoLabel.text = "이 활동은 어떤 활동이었는지 기록해봐요"
        }
        
        self.satisfactionLabel.setSatisfyingLabelEdit(by: activity.star)
        self.addCategoryView.setTitleAndColor(by: activity.categoryName)
        self.addCategoryView.setViewisHomeDetail()
        
        // 경제활동 반복
        // 기존의 recurrence가 없던 녀석들도 고려해야함
        if let recurrenceInfo = activity.recurrenceInfo, let recurrenceYN = activity.recurrenceYN {
            if recurrenceYN == "Y" {
                addScheduleTapView.setTitle(by: recurrenceInfo)
                remakeConstraintsByAddCScheduleTapView()
                addScheduleTapView.isHidden = false
            } else {    // 반복이 아닌 경우
                addScheduleTapView.isHidden = true
                remakeConstraintsByAddCategoryView()
            }
        } else {        // 기존에 있던 경제활동은 반복을 response하지 않으므로 hidden 처리
            addScheduleTapView.isHidden = true
            remakeConstraintsByAddCategoryView()
        }
    }
}

// MARK: - Loading Func
extension DetailViewController2 {
//    func showSnack() {
//        let snackView = SnackView(viewModel: homeDetailViewModel, idList: economicActivityId, index: index)
//        snackView.setSnackAttribute()
//        self.view.addSubview(snackView)
//        snackView.snp.makeConstraints {
//            $0.left.right.equalTo(view.safeAreaLayoutGuide).inset(24)
//            $0.bottom.equalTo(bottomPageControlView.snp.top).offset(-16)
//            $0.height.equalTo(40)
//        }
//        
//        snackView.toastAnimation(duration: 1.0, delay: 3.0, option: .curveEaseOut)
//    }
//    
    func showLoadingView(_ isLoading: Bool) {
        if isLoading {
            self.loadingView.play()
            self.loadingView.isPresent = true
            self.loadingView.modalPresentationStyle = .overFullScreen
            self.present(self.loadingView, animated: false)
        } else {
            self.loadingView.dismiss(animated: false)
        }
    }
}

//MARK: - Attribute & Hierarchy & Layouts
extension DetailViewController2 {
    override func setAttribute() {
        super.setAttribute()

        bottomPageControlView.reactor = self.reactor
        
        editActivityButtonItem = editActivityButtonItem.then {
            $0.customView = editButton
        }
        
        starList.forEach {
            $0.contentMode = .scaleAspectFit
            starStackView.addArrangedSubview($0) }
        
        
        starStackView = starStackView.then {
            $0.axis = .horizontal
            $0.distribution = .fillEqually
            $0.spacing = 7.54
        }
        
        editButton = editButton.then {
            $0.setTitle("편집", for: .normal)
        }
        
        titleLabel = titleLabel.then {
            $0.font = R.Font.body0
            $0.textColor = R.Color.gray200
        }
        
        scrollView = scrollView.then {
            $0.delegate = self
            $0.showsVerticalScrollIndicator = false
            $0.showsHorizontalScrollIndicator = false
            $0.isScrollEnabled = true
        }
        
        satisfactionLabel = satisfactionLabel.then {
            $0.backgroundColor = R.Color.gray700
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true
            $0.textColor = R.Color.gray100
            $0.font = R.Font.body4
        }
        
        mainImageView = mainImageView.then {
            $0.image = R.Icon.camera48
            $0.backgroundColor = R.Color.gray100
            $0.contentMode = .scaleToFill
            $0.isHidden = true
        }
        
        cameraImageView = cameraImageView.then {
            $0.isHidden = true
            $0.layer.zPosition = 1000
        }
        
        memoLabel = memoLabel.then {
            $0.text = "이 활동은 어떤 활동이었는지 기록해봐요"
            $0.textColor = R.Color.gray400
            $0.font = R.Font.body3

            $0.numberOfLines = 0
        }
    }
    
    override func setHierarchy() {
        super.setHierarchy()
        
        navigationItem.rightBarButtonItem = editActivityButtonItem
        
        view.addSubviews(titleLabel, scrollView, bottomPageControlView)
        
        contentView.addSubviews(addScheduleTapView, addCategoryView, separatorView, starStackView, mainImageView, cameraImageView, memoLabel, satisfactionLabel)
        scrollView.addSubviews(contentView)
    }
    
    override func setLayout() {
        super.setLayout()
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            $0.left.equalToSuperview().inset(24)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview().inset(90)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(24)
        }
        
        addCategoryView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.right.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        addScheduleTapView.snp.makeConstraints {
            $0.top.equalTo(addCategoryView.snp.bottom).offset(12)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        separatorView.snp.makeConstraints {
            $0.top.equalTo(addScheduleTapView.snp.bottom).offset(16)
            $0.left.right.equalToSuperview()
        }
        
        starStackView.snp.makeConstraints {
            $0.top.equalTo(separatorView.snp.bottom).offset(16)
            $0.left.equalToSuperview()
            $0.height.equalTo(24)
            $0.width.equalTo(120)
        }
        
        satisfactionLabel.snp.makeConstraints {
            $0.left.equalTo(starStackView.snp.right).offset(8)
            $0.centerY.equalTo(starStackView)
        }
        
        mainImageView.snp.makeConstraints {
            $0.top.equalTo(starStackView.snp.bottom).offset(16)
            $0.width.equalTo(view.safeAreaLayoutGuide).offset(-48)
            $0.height.equalTo(mainImageView.snp.width)
            $0.left.right.equalToSuperview()
        }
        
        cameraImageView.snp.makeConstraints {
            $0.top.equalTo(starStackView.snp.bottom).offset(16)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(144)
        }
        
        memoLabel.snp.makeConstraints {
            $0.top.equalTo(cameraImageView.snp.bottom).offset(16)
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        bottomPageControlView.snp.makeConstraints {
            $0.height.equalTo(55)
            $0.left.right.equalToSuperview().inset(24)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(UIDevice.hasNotch ? 0 : 20)
        }
    }
}

// MARK: - remakeConstraints
extension DetailViewController2 {
    /// mainImageView 기준으로 memoLabel의 뷰를 다시 배치하는 메서드
    private func remakeConstraintsByMainImageView() {
        memoLabel.snp.remakeConstraints {
            $0.top.equalTo(mainImageView.snp.bottom).offset(16)
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    /// cameraImageView 기준으로 memoLabel의 뷰를 다시 배치하는 메서드
    private func remakeConstraintsByCameraImageView() {
        memoLabel.snp.remakeConstraints {
            $0.top.equalTo(cameraImageView.snp.bottom).offset(16)
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    private func remakeConstraintsByAddCategoryView() {
        separatorView.snp.remakeConstraints {
            $0.top.equalTo(addCategoryView.snp.bottom).offset(16)
            $0.left.right.equalToSuperview()
        }
    }
    
    private func remakeConstraintsByAddCScheduleTapView() {
        separatorView.snp.remakeConstraints {
            $0.top.equalTo(addScheduleTapView.snp.bottom).offset(16)
            $0.left.right.equalToSuperview()
        }
    }
}
