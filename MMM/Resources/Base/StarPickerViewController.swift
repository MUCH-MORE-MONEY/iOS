//
//  StarViewController.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/05/27.
//

import UIKit
import Then
import SnapKit
import Combine

class StarPickerViewController: UIViewController {
    // MARK: - UI Components
    private lazy var headerStackView = UIStackView()
    private lazy var titleLabel = UILabel()
    private lazy var checkButton = UIButton()
    private lazy var satisfyingLabel = BasePaddingLabel(padding: UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12))
    private lazy var starStackView = UIStackView()
    private lazy var starList: [UIImageView] = [
        UIImageView(image: R.Icon.iconStarGray48),
        UIImageView(image: R.Icon.iconStarGray48),
        UIImageView(image: R.Icon.iconStarGray48),
        UIImageView(image: R.Icon.iconStarGray48),
        UIImageView(image: R.Icon.iconStarGray48)
    ]
    // MARK: - Properties
    private var cancellable = Set<AnyCancellable>()
    weak var delegate: BottomSheetChild?
    
    private let feedbackGenerator = UISelectionFeedbackGenerator()
    private var selectedRate: Int = 3
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
    }
}

// MARK: - Style & Layout & Bind
extension StarPickerViewController {
    private func setup() {
        setAttribute()
        setLayout()
//        bind()
    }
    
    private func setAttribute() {
        view.addSubviews(headerStackView, satisfyingLabel, starStackView)
        headerStackView.addSubviews(titleLabel, checkButton)
        
        headerStackView.addArrangedSubviews(titleLabel, checkButton)
        
        createStars()
        //        starList.enumerated().forEach { (index, value) in
        //            value.contentMode = .scaleAspectFit
        //            value.isUserInteractionEnabled = true
        //            value.tag = index
        //            starStackView.addArrangedSubview(value)
        //        }
        
        headerStackView = headerStackView.then {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.distribution = .equalCentering
        }
        
        titleLabel = titleLabel.then {
            $0.text = "만족도 설정"
            $0.font = R.Font.h5
            $0.textColor = R.Color.black
            $0.textAlignment = .left
        }
        
        checkButton = checkButton.then {
            $0.setTitle("확인", for: .normal)
            $0.setTitleColor(R.Color.gray500, for: .normal)
            $0.contentHorizontalAlignment = .right
            $0.titleLabel?.font = R.Font.title3
        }
        
        satisfyingLabel = satisfyingLabel.then {
            $0.text = "별점이 비어있어요"
            $0.backgroundColor = R.Color.gray700
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true
            $0.textColor = R.Color.gray100
            $0.font = R.Font.body4
        }
        
        starStackView = starStackView.then {
            $0.axis = .horizontal
            $0.spacing = 23
            $0.distribution = .fillEqually
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectStarRate))
            $0.addGestureRecognizer(tapGesture)
        }
    }
    
    private func setLayout() {
        headerStackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().inset(24)
            $0.trailing.equalToSuperview().inset(28)
        }
        
        satisfyingLabel.snp.makeConstraints {
            $0.top.equalTo(headerStackView.snp.bottom).offset(18)
            $0.centerX.equalToSuperview()
        }
        
        starStackView.snp.makeConstraints {
            $0.top.equalTo(satisfyingLabel.snp.bottom).offset(12)
            $0.left.right.equalToSuperview().inset(52)
            $0.height.equalTo(48)
        }
    }
    
    // MARK: - Bind
    private func bind() {
        starStackView.gesturePublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] gesture in
                guard let self = self else { return }
                //                let gesture1 = UITapGestureRecognizer()
                //                selectStarRate(gesture: gesture1)
                //                print(gesture)
                
                switch gesture {
                case let .tap(tapRecognizer):
                    print("Tapped !")
                    let location = tapRecognizer.location(in: tapRecognizer.view)
                    print(location)
                case let .swipe(swipeRecognizer):
                    print("Swiped !")
                    let location = swipeRecognizer.location(in: swipeRecognizer.view)
                    print(location)
                case let .longPress(longPressRecognizer):
                    print("Long pressed !")
                case let .pan(panRecognizer):
                    print("Panned !")
                case let .pinch(pinchRecognizer):
                    print("Pinched !")
                case let .edge(edgesRecognizer):
                    print("Panned edges !")
                }
                
                
                
                let location = gesture.get().location(in: gesture.get().view)
                print("location", location)
//                selectStarRate(gesture: gesture.get() as! UITapGestureRecognizer)
            }.store(in: &cancellable)
        
        //        starList.forEach {
        //            $0.gesturePublisher()
        //                .receive(on: DispatchQueue.main)
        //                .sink { gesture in
        ////                    self.
        //                }
        //        }
    }
}

// MARK: - Action
extension StarPickerViewController {
    @objc func selectStarRate(gesture: UITapGestureRecognizer) {
        
        
        
        let location = gesture.location(in: starStackView)
        print(location)
        //        let location = gesture.location(in: gesture.view)
        //        print(gesture.location(in: gesture.view))
        
        //        print(location)
        let starWidth = starStackView.bounds.width / CGFloat(starList.count)
        let rate = Int(location.x / starWidth) + 1
        /// if current star doesn't match selectedRate then we change our rating
        if rate != self.selectedRate {
            feedbackGenerator.selectionChanged()
            self.selectedRate = rate
        }
        
        /// loop through starsContainer arrangedSubviews and
        /// look for all Subviews of type UIImageView and change
        /// their isHighlighted state (icons depend on it)
        starStackView.arrangedSubviews.forEach {
            guard let starImageView = $0 as? UIImageView else {
                return
            }
            
            starImageView.isHighlighted = starImageView.tag <= rate
        }
    }
}

// MARK: - UI Function
extension StarPickerViewController {
    private func createStars() {
        /// loop through the number of our stars and add them to the stackView (starsContainer)
        for index in 1...5 {
            let star = makeStarIcon()
            star.tag = index
            starStackView.addArrangedSubview(star)
        }
    }
    
    private func makeStarIcon() -> UIImageView {
        /// declare default icon and highlightedImage
        let imageView = UIImageView(image: R.Icon.iconStarGray48, highlightedImage: R.Icon.iconStarBlack48)
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        return imageView
    }
}
