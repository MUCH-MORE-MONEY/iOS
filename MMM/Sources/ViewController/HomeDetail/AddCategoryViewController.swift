//
//  AddCategoryViewController.swift
//  MMM
//
//  Created by Park Jungwoo on 10/16/23.
//

import UIKit
import SnapKit
import Then
import Combine

final class AddCategoryViewController: UIViewController {
    // MARK: - Properties
    private lazy var cancellables: Set<AnyCancellable> = .init()
    private var isDark: Bool = false
    private var viewModel: AnyObject
    private let addCategoryViewModel = AddCategoryViewModel()
    weak var delegate: BottomSheetChild?
    // MARK: - UI Components
    private lazy var stackView = UIStackView() //Label, 확인 Button
    private lazy var titleLabel = UILabel()
    private lazy var buttonStackView = UIStackView()
    private lazy var manageButton = UIButton()
    private lazy var checkButton = UIButton()
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    init(viewModel: AnyObject) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    // Compile time에 error를 발생시키는 코드
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.endEditing(true)
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

// MARK: - Action
extension AddCategoryViewController {
    private func willDismiss() {
        delegate?.willDismiss()
        
        if let editViewModel = viewModel as? EditActivityViewModel {
            editViewModel.categoryName = addCategoryViewModel.selectedCategoryName
            editViewModel.categoryId = addCategoryViewModel.selectedCategoryID
        }
    }
    
    private func layout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
            // 아이템의 크기 정의
            let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(100),
                                                  heightDimension: .estimated(30))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            // 수평 그룹 생성
            let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(100),
                                                   heightDimension: .estimated(30))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            group.interItemSpacing = NSCollectionLayoutSpacing.fixed(8) // 아이템 간의 간격
            
            // 섹션 생성 및 구성
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary // 수평 스크롤 설정

            section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 20, trailing: 0) // 섹션 간격 설정
            section.interGroupSpacing = 8 // 그룹 간의 간격
            
            // 섹션의 헤더 (제목) 설정
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(24))
            let headerElement = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                            elementKind: UICollectionView.elementKindSectionHeader,
                                                                            alignment: .top)
            section.boundarySupplementaryItems = [headerElement]
            
            return section
        }
        
        return layout
    }
}

//MARK: - Attribute & Hierarchy & Layouts
private extension AddCategoryViewController {
    private func setup() {
        bind()
        setAttribute()
        setLayout()
    }
    
    private func bind() {
        guard let viewModel = viewModel as? EditActivityViewModel else { return }
        let date = viewModel.createAt
        let dvcd = viewModel.type
        // 뷰가 생성될때 카테고리편집에서 온 경우일수도 있기 때문에 항상 초기화해줌
        viewModel.isViewFromCategoryViewController = false
        
        addCategoryViewModel.getCategoryList(date: date, dvcd: dvcd)
        
        checkButton.tapPublisher
            .sinkOnMainThread(receiveValue: willDismiss)
            .store(in: &cancellables)
        
        manageButton.tapPublisher
            .sinkOnMainThread { [weak self] _ in
                guard let self = self else { return }
                
                if let viewModel = self.viewModel as? EditActivityViewModel {
                    delegate?.willDismiss()
                    viewModel.isCategoryManageButtonTapped = true
                }
                print("관리 버튼 Tapped")
            }
            .store(in: &cancellables)
        
        addCategoryViewModel.$categoryList
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func setAttribute() {
        self.view.backgroundColor = isDark ? R.Color.gray900 : .white
        
        stackView = stackView.then {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.distribution = .equalCentering
        }
        
        titleLabel = titleLabel.then {
            $0.text = "카테고리 선택"
            $0.font = R.Font.h5
            $0.textColor = isDark ? R.Color.gray200 : R.Color.black
            $0.textAlignment = .left
        }
        
        buttonStackView = buttonStackView.then {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.spacing = 24
        }
        
        checkButton = checkButton.then {
            $0.setTitle("확인", for: .normal)
            $0.setTitleColor(isDark ? R.Color.gray200 : R.Color.black, for: .normal)
            $0.setTitleColor(isDark ? R.Color.gray200.withAlphaComponent(0.7) : R.Color.black.withAlphaComponent(0.7), for: .highlighted)
            $0.contentHorizontalAlignment = .right
            $0.titleLabel?.font = R.Font.title3
            //            $0.contentEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10) // touch 영역 늘리기
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
            $0.collectionViewLayout = layout()
            $0.backgroundColor = R.Color.white
            $0.delegate = self
            $0.dataSource = self
            $0.register(CategorySelectCell.self, forCellWithReuseIdentifier: "CategorySelectCell")
            $0.register(CategorySelectHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CategorySelectHeaderCell")
            $0.isScrollEnabled = true
        }
    }
    
    private func setLayout() {
        stackView.addArrangedSubviews(titleLabel, buttonStackView)
        buttonStackView.addArrangedSubviews(manageButton, checkButton)
        view.addSubviews(stackView, collectionView)
        
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().inset(24)
            $0.trailing.equalToSuperview().inset(28)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(24)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension AddCategoryViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return addCategoryViewModel.categoryList.isEmpty ? 0 : addCategoryViewModel.categoryList[section].lowwer.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategorySelectCell", for: indexPath) as? CategorySelectCell else { return UICollectionViewCell()}
        
        let title = addCategoryViewModel.categoryList[indexPath.section].lowwer[indexPath.item].title
        
        if let viewModel = viewModel as? EditActivityViewModel {
            cell.setData(title, viewModel.type == "01")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        // header
        let title = addCategoryViewModel.categoryList[indexPath.section].title
        
        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = collectionView
                .dequeueReusableSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: "CategorySelectHeaderCell",
                    for: indexPath) as? CategorySelectHeaderCell else { return CategorySelectHeaderCell() }
            header.setData(title)
            return header
        } else { // footer
            guard let footer = collectionView
                .dequeueReusableSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionFooter,
                    withReuseIdentifier: "CategorySelectHeaderCell",
                    for: indexPath) as? CategorySelectHeaderCell else { return CategorySelectHeaderCell() }
            footer.setData(title)
            return footer
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return addCategoryViewModel.categoryList.isEmpty ? 0 : addCategoryViewModel.categoryList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        addCategoryViewModel.selectedCategoryID = addCategoryViewModel.categoryList[indexPath.section].lowwer[indexPath.item].id
        addCategoryViewModel.selectedCategoryName = addCategoryViewModel.categoryList[indexPath.section].lowwer[indexPath.item].title
    }
}

// MARK: - 이거 보면서 바꾸기
//// MARK: - UICollectionView DelegateFlowLayout
//extension CategoryContentViewController: UICollectionViewDelegateFlowLayout {
//    // 지정된 섹션의 헤더뷰의 크기를 반환하는 메서드. 크기를 지정하지 않으면 화면에 보이지 않습니다.
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        return CGSize(width: (collectionView.frame.width) / 2, height: UI.headerHeight)
//    }
//
//    // 지정된 섹션의 여백을 반환하는 메서드.
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UI.sectionMargin
//    }
//
//    // 지정된 섹션의 셀 사이의 최소간격을 반환하는 메서드.
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return UI.cellSpacingMargin
//    }
//
//    // 지정된 섹션의 행 사이 간격 최소 간격을 반환하는 메서드. scrollDirection이 horizontal이면 수직이 행이 되고 vertical이면 수평이 행이 된다.
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return UI.cellSpacingMargin
//    }
//
//    // 지정된 셀의 크기를 반환하는 메서드
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        switch dataSource[indexPath.section].items[indexPath.row] {
//        case .header:
//            return CGSize(width: collectionView.frame.width - UI.cellWidthMargin, height: UI.categoryCellHeight)
//        case .base:
//            return CGSize(width: collectionView.frame.width - UI.cellWidthMargin, height: UI.categoryCellHeight)
//        }
//    }
//}
