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
        $0.text = "그저 그래요"
    }

    private lazy var mainImage = UIImageView().then {
        $0.image = R.Icon.camera48
        $0.backgroundColor = R.Color.gray100
        $0.contentMode = .scaleToFill
    }
    
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
    private var economicActivityId: [String] = []
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
    
    private func setup() {
        setAttribute()
        setLayout()
        bind()
    }
    
    private func bind() {
        viewModel.$detailActivity
            .sinkOnMainThread { [weak self] value in
                guard let self = self, let value = value else { return }
                self.titleLabel.text = value.title
                for i in 0..<value.star {
                    starList[i].image = R.Icon.iconStarBlack24
                }
                self.mainImage.setImage(urlStr: value.imageUrl, defaultImage: R.Icon.camera48)
                self.memoLabel.text = value.memo
            }.store(in: &cancellable)
        
        viewModel.fetchDetailActivity(id: economicActivityId[index])
    }
    
    private func setAttribute() {
        
        navigationItem.rightBarButtonItem = editButton
        view.addSubviews(titleLabel, scrollView)

        contentView.addSubviews(starStackView, mainImage, memoLabel, satisfactionLabel)
        scrollView.addSubviews(contentView)
        starList.forEach {
            $0.contentMode = .scaleAspectFit
            starStackView.addArrangedSubview($0) }
    }
    
    private func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.left.equalToSuperview().inset(24)
            $0.right.equalToSuperview().inset(135)
            $0.bottom.equalTo(totalPrice.snp.top).offset(-8)
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
        
        mainImage.snp.makeConstraints {
            $0.top.equalTo(starStackView.snp.bottom).offset(16)
            $0.width.equalTo(view.safeAreaLayoutGuide).offset(-48)
            $0.height.equalTo(mainImage.image!.size.height * view.frame.width / mainImage.image!.size.width)
            $0.left.right.equalToSuperview()
//            $0.centerY.equalToSuperview()
        }
        
        memoLabel.snp.makeConstraints {
            $0.top.equalTo(mainImage.snp.bottom).offset(16)
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