//
//  AddCategorySheetViewController.swift
//  MMM
//
//  Created by yuraMacBookPro on 1/22/24.
//

import UIKit
import ReactorKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class AddCategorySheetViewController: BottomSheetViewController2, View {
    typealias Reactor = AddCategorySheetViewReactor
    
    // MARK: - UI Components
    private lazy var containerView = UIView()
    private lazy var stackView = UIStackView() //Label, 확인 Button
    private lazy var titleLabel = UILabel()
    private lazy var buttonStackView = UIStackView()
    private lazy var manageButton = UIButton()
    private lazy var checkButton = UIButton()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private lazy var shadowView = UIView()
    
    // 카테고리 데이터가 없을 경우를 위한 image
    private lazy var emptyImageView = UIImageView()
    private lazy var emptyLabel = UILabel()
    private lazy var emptyStackView = UIStackView()
    
    
    // MARK: - Properties
    private var titleStr: String = ""
    private var height: CGFloat
    private var isDark: Bool = false
    
    init(title: String, height: CGFloat, isDark: Bool = false) {
        self.titleStr = title
        self.height = height
        self.isDark = isDark
        super.init(mode: .drag, isDark: isDark)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()


    }
    
    func bind(reactor: AddCategorySheetViewReactor) {
        bindAction(reactor)
        bindState(reactor)
    }
}

// MARK: - Bind
extension AddCategorySheetViewController {
    private func bindAction(_ reactor: AddCategorySheetViewReactor) {
        
    }
    
    private func bindState(_ reactor: AddCategorySheetViewReactor) {
        
    }
}

// MARK: - Actions
extension AddCategorySheetViewController {
    
}

//MARK: - Attribute & Hierarchy & Layouts
extension AddCategorySheetViewController {
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
    }
    
    override func setHierarchy() {
        super.setHierarchy()
        
        containerView.addSubviews(stackView)
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
    }
}
