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

class DetailViewController: BaseDetailViewController {
    // MARK: - UI Components
    private lazy var starStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 7.54
    }
    
    private lazy var editButton = UIBarButtonItem().then {
        $0.title = "편집"
        $0.style = .plain
        $0.target = self
        $0.action = #selector(didTapEditButton)
    }
    
    private lazy var titleLabel = UILabel().then {
        $0.font = R.Font.body0
        $0.textColor = R.Color.gray200
    }
    
    private lazy var scrollView = UIScrollView().then {
        $0.delegate = self
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.isScrollEnabled = true
    }
    
    private lazy var contentView = UIView()
    
    private lazy var satisfactionLabel = BasePaddingLabel(padding: UIEdgeInsets(top: 3, left: 12, bottom: 3, right: 12)).then {
        $0.backgroundColor = R.Color.gray700
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
        $0.textColor = R.Color.gray100
        $0.font = R.Font.body4
    }

    private lazy var mainImageView = UIImageView().then {
        $0.image = R.Icon.camera48
        $0.backgroundColor = R.Color.gray100
        $0.contentMode = .scaleToFill
        $0.isHidden = false
    }
    
    private lazy var cameraImageView = CameraImageView().then {
        $0.isHidden = false
        $0.layer.zPosition = 1000
    }
    
    private lazy var bottomPageControlView = BottomPageControlView()
    
    private lazy var memoLabel = UILabel().then {
        $0.text = "이 활동은 어떤 활동이었는지 기록해봐요"
        $0.textColor = R.Color.gray500
        $0.font = R.Font.body3
    }
    private lazy var starList: [UIImageView] = [
        UIImageView(image: R.Icon.iconStarInActive),
        UIImageView(image: R.Icon.iconStarInActive),
        UIImageView(image: R.Icon.iconStarInActive),
        UIImageView(image: R.Icon.iconStarInActive),
        UIImageView(image: R.Icon.iconStarInActive)
    ]
    // MARK: - Properties
    private var viewModel = HomeDetailViewModel()
    /// cell에 보여지게 되는 id의 배열
    private var economicActivityId: [String] = []
    /// 현재 보여지고 있는 indexPath.row
    private var index: Int = 0
    private var cancellable = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

extension DetailViewController {
    func setData(economicActivityId: [String], index: Int) {
        self.economicActivityId = economicActivityId
        self.index = index
    }
    
    func setNavigation(_ title :String) {
        self.title = title
    }
    private func setup() {
        setAttribute()
        setLayout()
        bind()
    }
    
    private func bind() {
        viewModel.fetchDetailActivity(id: economicActivityId[index])
        
        viewModel.$detailActivity
            .sinkOnMainThread { [weak self] value in
                guard let self = self, let value = value else { return }
                self.titleLabel.text = value.title
                
				self.starList.forEach {
                    $0.image = R.Icon.iconStarGray24
                }
                
                for i in 0..<value.star {
					self.starList[i].image = R.Icon.iconStarBlack24
                }
                
                if URL(string: value.imageUrl) != nil {
					self.mainImageView.isHidden = false
					self.cameraImageView.isHidden = true
                    self.mainImageView.setImage(urlStr: value.imageUrl, defaultImage: R.Icon.camera48)
					self.remarkConstraintsByMainImageView()
                } else {
					self.mainImageView.isHidden = true
					self.cameraImageView.isHidden = false
					self.remarkConstraintsByCameraImageView()
                }
                
                if let amount = Int(value.amount) {
                    self.totalPrice.text = "\(amount.withCommas())원"
                }
                self.memoLabel.text = value.memo
                
                switch value.star {
                case 0:
					self.satisfactionLabel.isHidden = true
                case 1:
					self.satisfactionLabel.text = "아쉬워요"
                case 2:
					self.satisfactionLabel.text = "그저그래요"
                case 3:
					self.satisfactionLabel.text = "괜찮아요"
                case 4:
					self.satisfactionLabel.text = "만족해요"
                case 5:
					self.satisfactionLabel.text = "완전 만족해요"
                default:
                    break
                }
            }.store(in: &cancellable)
        
        bottomPageControlView.setViewModel(viewModel, index, economicActivityId)
    }
    
    private func setAttribute() {
        
        navigationItem.rightBarButtonItem = editButton
        view.addSubviews(titleLabel, scrollView, bottomPageControlView)
        contentView.addSubviews(starStackView, mainImageView, cameraImageView, memoLabel, satisfactionLabel)
        scrollView.addSubviews(contentView)
        starList.forEach {
            $0.contentMode = .scaleAspectFit
            starStackView.addArrangedSubview($0) }
    }
    
    private func setLayout() {
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
        
        starStackView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.top.equalToSuperview()
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
            $0.height.equalTo(mainImageView.image!.size.height * view.frame.width / mainImageView.image!.size.width)
            $0.left.right.equalToSuperview()
        }
        
        cameraImageView.snp.makeConstraints {
            $0.top.equalTo(starStackView.snp.bottom).offset(16)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(200)
        }
        
        memoLabel.snp.makeConstraints {
            $0.top.equalTo(cameraImageView.snp.bottom).offset(16)
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        bottomPageControlView.snp.makeConstraints {
            $0.height.equalTo(90)
            $0.left.right.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview()
        }
    }
    /// mainImageView 기준으로 memoLabel의 뷰를 다시 배치하는 메서드
    private func remarkConstraintsByMainImageView() {
        memoLabel.snp.remakeConstraints {
            $0.top.equalTo(mainImageView.snp.bottom).offset(16)
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    /// cameraImageView 기준으로 memoLabel의 뷰를 다시 배치하는 메서드
    private func remarkConstraintsByCameraImageView() {
        memoLabel.snp.remakeConstraints {
            $0.top.equalTo(cameraImageView.snp.bottom).offset(16)
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}

// MARK: - Action
private extension DetailViewController {
    @objc func didTapEditButton(_ sener: UITapGestureRecognizer) {
        print("edit Tapped")
    }
}

// MARK: - Scrollview delegate
extension DetailViewController: UIScrollViewDelegate {
    
}
