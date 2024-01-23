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
import RxDataSources

final class CategorySheetViewController: BottomSheetViewController2, View {
    typealias Reactor = CategorySheetViewReactor
    typealias DataSource = RxCollectionViewSectionedReloadDataSource<CategorySheetSectionModel>
    
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
    private lazy var dataSource = DataSource { [weak self] _, collectionView, indexPath, item -> UICollectionViewCell in
        guard let reactor = self?.reactor else { return .init() }
        
        switch item {
        case let .base(cellReactor):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategorySelectCell.className, for: indexPath) as? CategorySelectCell else { return .init() }
            
            return cell
        }
    } configureSupplementaryView: { [weak self] dataSource, collectionView, kind, indexPath in
        guard let thisReactor = self?.reactor else { return .init() }
        
        if kind == UICollectionView.elementKindSectionHeader {
            switch dataSource[indexPath.section].model {
            case .base:
                guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CategorySelectHeaderCell.className, for: indexPath) as? CategorySelectHeaderCell else { return .init() }
                let sectionInfo = dataSource.sectionModels[indexPath.section].model.header
                
                return header
            }
        } else {
            switch dataSource[indexPath.section].model {
            case .base:
                guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CategorySelectHeaderCell.className, for: indexPath) as? CategorySelectHeaderCell else { return .init() }
                let sectionInfo = dataSource.sectionModels[indexPath.section].model.header
                
                return header
            }
        }
    }
    
    
    
    init(title: String, height: CGFloat, isDark: Bool = false) {
        self.titleStr = title
        self.height = height
        self.isDark = isDark
        super.init(mode: .drag, isDark: isDark)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()


    }
    
    func bind(reactor: CategorySheetViewReactor) {
        bindAction(reactor)
        bindState(reactor)
    }
}

// MARK: - Bind
extension CategorySheetViewController {
    private func bindAction(_ reactor: CategorySheetViewReactor) {
        reactor.action.onNext(.loadData)
        
        collectionView.rx.itemSelected
            .map { .loadData }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(_ reactor: CategorySheetViewReactor) {
        
    }
}

// MARK: - Actions
extension CategorySheetViewController {
    
}

//MARK: - Attribute & Hierarchy & Layouts
extension CategorySheetViewController {
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
        
        manageButton = manageButton.then {
            $0.setTitle("관리", for: .normal)
            $0.setTitleColor(isDark ? R.Color.gray200 : R.Color.black, for: .normal)
            $0.setTitleColor(isDark ? R.Color.gray200.withAlphaComponent(0.7) : R.Color.black.withAlphaComponent(0.7), for: .highlighted)
            $0.contentHorizontalAlignment = .right
            $0.titleLabel?.font = R.Font.title3
            //            $0.contentEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10) // touch 영역 늘리기
        }
        
        collectionView = collectionView.then {
            let layer = LeftAlignedCollectionViewFlowLayout()
            layer.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
            $0.showsVerticalScrollIndicator = false
            $0.collectionViewLayout = layer
            $0.backgroundColor = R.Color.white
//            $0.delegate = self
//            $0.dataSource = self
            $0.register(CategorySelectCell.self, forCellWithReuseIdentifier: "CategorySelectCell")
            $0.register(CategorySelectHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CategorySelectHeaderCell")
            $0.isScrollEnabled = true
            $0.isHidden = true
        }
        
        emptyStackView = emptyStackView.then {
            $0.axis = .vertical
            $0.distribution = .fill
            $0.spacing = 16
        }
        
        emptyImageView = emptyImageView.then {
            $0.image = R.Icon.iconCharacterEmptyCategory
            $0.contentMode = .scaleAspectFit
        }
        
        emptyLabel = emptyLabel.then {
            $0.text = "선택할 수 있는 카테고리가 없어요.\n관리 페이지에서 추가해주세요!"
            $0.numberOfLines = 0
            $0.font = R.Font.body1
            $0.textColor = R.Color.gray400
            $0.textAlignment = .center
        }
        
        shadowView = shadowView.then {
            $0.clipsToBounds = false
            $0.backgroundColor = R.Color.white
            $0.layer.applyShadow(alpha: 0.2, y: 4, blur: 20)
        }
    }
    
    override func setHierarchy() {
        super.setHierarchy()
        
        containerView.addSubviews(stackView, collectionView, shadowView, emptyStackView)
        stackView.addArrangedSubviews(titleLabel, manageButton, checkButton)
        emptyStackView.addArrangedSubviews(emptyImageView, emptyLabel)
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
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(24)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
            $0.bottom.equalToSuperview().offset(-58)
        }
        
        shadowView.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        emptyStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
