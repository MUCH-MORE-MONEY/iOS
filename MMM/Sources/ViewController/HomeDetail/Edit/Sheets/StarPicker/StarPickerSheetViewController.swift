//
//  StarPickerViewController2.swift
//  MMM
//
//  Created by yuraMacBookPro on 1/19/24.
//

import UIKit
import Then
import SnapKit
import RxSwift
import Cosmos
import ReactorKit

final class StarPickerSheetViewController: BottomSheetViewController2, View {
    typealias Reactor = StarPickerSheetReactor
    // MARK: - UI Components
    private lazy var containerView = UIView()
    private lazy var stackView = UIStackView()
    private lazy var titleLabel = UILabel()
    private lazy var checkButton = UIButton()
    private lazy var satisfyingLabel = BasePaddingLabel(padding: UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12))
    private lazy var cosmosView = CosmosView()
    
   
    // MARK: - Property Wrapper
    private var rating = 0.0
    private var titleStr: String = ""
    private var height: CGFloat
    private var isDark: Bool = false // 다크 모드 지정
    
    init(title: String = "", height: CGFloat, sheetMode: BottomSheetViewController2.Mode = .drag, isDark: Bool = false) {
        self.titleStr = title
        self.height = height
        self.isDark = isDark
        super.init(mode: sheetMode, isDark: isDark)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Tracking.FinActAddPage.inputRatingLogEvent(Int(rating))
    }
    
    func bind(reactor: StarPickerSheetReactor) {
        binAction(reactor)
        bindState(reactor)
    }
}

// MARK: - Bind
extension StarPickerSheetViewController {
    private func binAction(_ reactor: StarPickerSheetReactor) {
//        checkButton.rx.tap
//            .withUnretained(self)
//            .map { $0 }
//            .bind(to: reactor.action)
//            .disposed(by: disposeBag)
    }
    
    private func bindState(_ reactor: StarPickerSheetReactor) {
        reactor.state
            .map { $0.dismiss }
            .distinctUntilChanged()
            .filter { $0 }
            .withUnretained(self)
            .subscribe { _ in
                self.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Actions
extension StarPickerSheetViewController {
    
}

//MARK: - Attribute & Hierarchy & Layouts
extension StarPickerSheetViewController {
    override func setAttribute() {
        super.setAttribute()
        
        containerView = containerView.then {
            $0.backgroundColor = isDark ? R.Color.gray900 : .white
        }
        
        stackView = stackView.then {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.distribution = .equalCentering
        }
        
        titleLabel = titleLabel.then {
            $0.text = titleStr
            $0.font = R.Font.h5
            $0.textColor = isDark ? R.Color.gray200 : R.Color.black
            $0.textAlignment = .left
        }
        
        checkButton = checkButton.then {
            $0.setTitle("확인", for: .normal)
            $0.setTitleColor(isDark ? R.Color.gray200 : R.Color.black, for: .normal)
            $0.setTitleColor(isDark ? R.Color.gray200.withAlphaComponent(0.7) : R.Color.black.withAlphaComponent(0.7), for: .highlighted)
            $0.contentHorizontalAlignment = .right
            $0.titleLabel?.font = R.Font.title3
            $0.contentEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10) // touch 영역 늘리기
        }
        
        satisfyingLabel = satisfyingLabel.then {
            $0.text = "별점이 비어있어요"
            $0.backgroundColor = R.Color.gray700
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true
            $0.textColor = R.Color.gray100
            $0.font = R.Font.body4
        }
        
        cosmosView = cosmosView.then {
            $0.settings.filledImage = R.Icon.iconStarBlack48
            $0.settings.emptyImage = R.Icon.iconStarGray48
            $0.settings.totalStars = 5
            $0.settings.starSize = 32
            $0.settings.starMargin = 23.08
            $0.settings.fillMode = .full
            $0.rating = rating
        }
    }
    
    override func setHierarchy() {
        super.setHierarchy()
        
        containerView.addSubviews(stackView, satisfyingLabel, cosmosView)
        stackView.addArrangedSubviews(titleLabel, checkButton)
        addContentView(view: containerView)
    }
    
    override func setLayout() {
        super.setLayout()
        
        containerView.snp.makeConstraints {
            $0.height.equalTo(height - 32.0) // 32(Super Class의 Drag 영역)를 반드시 뺴줘야한다.
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().inset(24)
            $0.trailing.equalToSuperview().inset(28)
        }
        
        satisfyingLabel.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(18)
            $0.centerX.equalToSuperview()
        }
        
        cosmosView.snp.makeConstraints {
            $0.top.equalTo(satisfyingLabel.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
        }
    }
}
