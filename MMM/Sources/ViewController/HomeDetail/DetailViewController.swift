//
//  DetailViewController.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/05/08.
//

import UIKit
import Then
import SnapKit
import Combine
import Lottie

class DetailViewController: BaseDetailViewController, UIScrollViewDelegate {
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
	private lazy var bottomPageControlView = BottomPageControlView()
	private lazy var memoLabel = UILabel()
	private lazy var starList: [UIImageView] = [
		UIImageView(image: R.Icon.iconStarDisabled16),
		UIImageView(image: R.Icon.iconStarDisabled16),
		UIImageView(image: R.Icon.iconStarDisabled16),
		UIImageView(image: R.Icon.iconStarDisabled16),
		UIImageView(image: R.Icon.iconStarDisabled16)
	]
    lazy var addCategoryView = AddCategoryView()
    private lazy var separatorView = SeparatorView()
	
	// MARK: - LoadingView
	private lazy var loadView = LoadingViewController()
	
	// MARK: - Properties
	private var date = Date()
	private var homeDetailViewModel = HomeDetailViewModel()
	private var homeViewModel: HomeViewModel
    private var editViewModel = EditActivityViewModel(isAddModel: false)
	/// cell에 보여지게 되는 id의 배열
	private var economicActivityId: [String] = []
	/// 현재 보여지고 있는 indexPath.row
	private var index: Int
	private var cancellable = Set<AnyCancellable>()
	
	private var navigationTitle: String {
		return date.getFormattedDate(format: "M월 dd일 경제활동")
	}
	
    init(homeViewModel: HomeViewModel, index: Int) {
		self.homeViewModel = homeViewModel
        self.index = index
		super.init(nibName: nil, bundle: nil)
	}
	
	// Compile time에 error를 발생시키는 코드
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
        // editVM을 공유하고 있기 때문에 Loading 값을 초기화
        editViewModel.isLoading = true

        // 날짜가 변경되었을 경우 다른 dailyList를 보여줘야함
        if homeDetailViewModel.isDateChanged {
            self.date = homeDetailViewModel.changedDate
            title = date.getFormattedDate(format: "M월 dd일 경제활동")
            
            homeDetailViewModel.fetchDailyList(date.getFormattedYMD()) { [weak self] in
                guard let self = self else { return }
                let list = self.homeDetailViewModel.dailyEconomicActivityId
                let changedID = self.homeDetailViewModel.changedId
                
                list.enumerated().forEach { i, id in
                    if changedID == id { self.homeDetailViewModel.pageIndex = i }
                }
                
                self.homeDetailViewModel.fetchDetailActivity(id: list[self.homeDetailViewModel.pageIndex]) {
                    self.bottomPageControlView.setViewModel(self.homeDetailViewModel, list)
                }
            }
        } else {
            self.homeDetailViewModel.fetchDetailActivity(id: self.economicActivityId[homeDetailViewModel.pageIndex])
            self.homeDetailViewModel.getMonthlyList(self.date.getFormattedYM())
        }
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		homeViewModel.date = date // 날짜가 변경되었을 경우
	}
}
//MARK: - Actions
extension DetailViewController {
	func setData(economicActivityId: [String], index: Int, date: Date) {
		self.economicActivityId = economicActivityId
		self.index = index
		self.date = date
	}
}
//MARK: - Attribute & Hierarchy & Layouts
extension DetailViewController {
	// MARK: - Bind
	override func setBind() {
		super.setBind()
        homeDetailViewModel.fetchDetailActivity(id: economicActivityId[index])

        // MARK: - Loading
        homeDetailViewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self = self else { return }
                if !$0 {
                    self.loadView.dismiss(animated: false)
                } else {

                }
            }.store(in: &cancellable)

        homeDetailViewModel.$isError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self = self else { return }
                if $0 {
                    showSnack()
                }
            }.store(in: &cancellable)
        
        editButton.tapPublisher
            .sinkOnMainThread(receiveValue: didTapEditButton)
            .store(in: &cancellable)
        
        homeDetailViewModel.$detailActivity
            .sinkOnMainThread { [weak self] value in
                guard let self = self, let value = value else { return }
                showLoadingView()
                self.titleLabel.text = value.title
                self.activityType.text = self.homeDetailViewModel.detailActivity?.type == "01" ? "지출" : "수입"
                self.activityType.backgroundColor = self.homeDetailViewModel.detailActivity?.type == "01" ? R.Color.orange500 : R.Color.blue500
                self.starList.forEach {
                    $0.image = R.Icon.iconStarGray16
                }
                
                for i in 0..<value.star {
                    self.starList[i].image = R.Icon.iconStarBlack16
                }
                
                if URL(string: value.imageUrl) != nil {
                    self.mainImageView.isHidden = false
                    self.cameraImageView.isHidden = true
                    self.mainImageView.setImage(urlStr: value.imageUrl, defaultImage: R.Icon.camera48)
                    self.remakeConstraintsByMainImageView()
                    self.homeDetailViewModel.hasImage = true
                } else {
                    self.mainImageView.isHidden = true
                    self.cameraImageView.isHidden = false
                    self.remakeConstraintsByCameraImageView()
                    self.homeDetailViewModel.hasImage = false
                }
                
                self.totalPrice.text = "\(value.amount.withCommas())원"
                if !value.memo.isEmpty {
                    self.memoLabel.text = value.memo
                    memoLabel.textColor = R.Color.black
                } else {
                    memoLabel.textColor = R.Color.gray400
                    self.memoLabel.text = "이 활동은 어떤 활동이었는지 기록해봐요"
                }
                
                self.satisfactionLabel .setSatisfyingLabelEdit(by: value.star)
            }.store(in: &cancellable)
        homeDetailViewModel.pageIndex = index
        bottomPageControlView.setViewModel(homeDetailViewModel, economicActivityId)

    }
    
	override func setAttribute() {
		super.setAttribute()
		title = navigationTitle
		editActivityButtonItem = editActivityButtonItem.then {
			$0.customView = editButton
		}
		
		navigationItem.rightBarButtonItem = editActivityButtonItem
		
		view.addSubviews(titleLabel, scrollView, bottomPageControlView)
		
		contentView.addSubviews(addCategoryView, separatorView, starStackView, mainImageView, cameraImageView, memoLabel, satisfactionLabel)
		scrollView.addSubviews(contentView)
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
        }
        
        separatorView.snp.makeConstraints {
            $0.top.equalTo(addCategoryView.snp.bottom).offset(40)
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
			//            $0.height.equalTo(mainImageView.image!.size.height * view.frame.width / mainImageView.image!.size.width)
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
}

// MARK: - Action
private extension DetailViewController {
	func didTapEditButton() {
		if cameraImageView.isHidden {
			let mainImage = mainImageView.image
			homeDetailViewModel.mainImage = mainImage
		} else {
			homeDetailViewModel.mainImage = nil
		}
		
		let vc = EditActivityViewController(detailViewModel: homeDetailViewModel, editViewModel: editViewModel, date: date)
		
		navigationController?.pushViewController(vc, animated: true)
	}
}

// MARK: - Loading Func
extension DetailViewController {
    func showSnack() {
        let snackView = SnackView(viewModel: homeDetailViewModel, idList: economicActivityId, index: index)
        snackView.setSnackAttribute()
        self.view.addSubview(snackView)
        snackView.snp.makeConstraints {
            $0.left.right.equalTo(view.safeAreaLayoutGuide).inset(24)
            $0.bottom.equalTo(bottomPageControlView.snp.top).offset(-16)
            $0.height.equalTo(40)
        }
        
        snackView.toastAnimation(duration: 1.0, delay: 3.0, option: .curveEaseOut)
    }
    
	func showLoadingView() {
		self.loadView.play()
		self.loadView.isPresent = true
		self.loadView.modalPresentationStyle = .overFullScreen
		self.present(self.loadView, animated: false)
	}
}
