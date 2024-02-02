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
    
    
    // MARK: - Constants
    private enum UI {
        static let topMargin: CGFloat = 0
        static let cellWidthMargin: CGFloat = 48
        static let cellHeightMargin: CGFloat = 44
        static let cellSpacingMargin: CGFloat = 16
        static let categoryCellHeight: CGFloat = 165
        static let headerHeight: CGFloat = 60
        static let sectionMargin: UIEdgeInsets = .init(top: 16, left: 24, bottom: 16, right: 24)
    }
    
    // MARK: - Properties
    private var titleStr: String = ""
    private var height: CGFloat
    private var isDark: Bool = false
    private lazy var dataSource = DataSource { [weak self] _, collectionView, indexPath, item -> UICollectionViewCell in
        guard let reactor = self?.reactor else { return .init() }
        
        switch item {
        case .header:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategorySheetCell.className, for: indexPath) as? CategorySheetCell else { return .init() }
            
            return cell
            
        case let .base(cellReactor):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategorySheetCell.className, for: indexPath) as? CategorySheetCell else { return .init() }
            
            cell.setData("test", true)
            
            return cell
        }
    } configureSupplementaryView: { [weak self] dataSource, collectionView, kind, indexPath in
        guard let thisReactor = self?.reactor else { return .init() }
        
        if kind == UICollectionView.elementKindSectionHeader {
            switch dataSource[indexPath.section].model {
            case .header:
                guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CategorySelectHeaderCell.className, for: indexPath) as? CategorySelectHeaderCell else { return .init() }
                
                return header
                
            case .base:
                guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CategorySelectHeaderCell.className, for: indexPath) as? CategorySelectHeaderCell else { return .init() }
                let sectionInfo = dataSource.sectionModels[indexPath.section].model.header
                
                header.setData("Title Test")
                return header
            }
        } else {
            switch dataSource[indexPath.section].model {
            case .header:
                guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CategorySelectHeaderCell.className, for: indexPath) as? CategorySelectHeaderCell else { return .init() }
                
                return header
                
            case .base:
                guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CategorySelectHeaderCell.className, for: indexPath) as? CategorySelectHeaderCell else { return .init() }
                let sectionInfo = dataSource.sectionModels[indexPath.section].model.header
                
                return header
            }
        }
    }
    
    
//    let dataSource1 = RxCollectionViewSectionedReloadDataSource<SectionModel<String, Item>>(configureCell: { (_, collectionView, indexPath, item) -> UICollectionViewCell in
//                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as! MyCollectionViewCell
//                cell.configure(with: item)
//                return cell
//            })
    
    
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
        
        Observable.zip(
            collectionView.rx.itemSelected,
            collectionView.rx.modelSelected(type(of: dataSource).Section.Item.self))
        .map { .selectCell($0, $1) }
        .bind(to: reactor.action)
        .disposed(by: disposeBag)
    }
    
    private func bindState(_ reactor: CategorySheetViewReactor) {
//        reactor.state
//            .map { $0.sections }
//            .withUnretained(self)
//            .subscribe(onNext: { (this, sections) in
//                this.dataSource.setSections(sections)
//                this.collectionView.collectionViewLayout = this.makeLayout(sections: sections) ?? UICollectionViewFlowLayout()
//                this.collectionView.reloadData()
//            })
//            .disposed(by: disposeBag)
    }
}

// MARK: - Actions
extension CategorySheetViewController {
    func makeLayout(sections: [CategorySheetSectionModel]) -> UICollectionViewCompositionalLayout? {
        debugPrint("section \(sections)")
        

        
        
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            
            guard let self = self else {
                debugPrint("self is nil")
                return nil
            }
            
//            debugPrint("layout 생성")
            
            switch sections[sectionIndex].model {
            case let .header(item):
                guard let layoutSection = self.makeCategorySheetHeaderSectionLayout(from: item) else {
                    debugPrint("Failed to create header section layout")
                    return nil
                }
                return layoutSection
            case .base(_, _):
                
                guard let layoutSection = self.makeCategorySheetSectionLayout(from: sections[sectionIndex].items) else {
                    debugPrint("Failed to create base section layout")
                    return nil
                }
                return layoutSection
            }
        }
        
        return layout
    }
    
    func makeCategorySheetSectionLayout(from section: [CategorySheetItem]) -> NSCollectionLayoutSection? {
        // 아이템 사이즈 구성
        debugPrint("section : \(section)")
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(32))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        // 아이템 간 간격 설정
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)

        // 그룹 사이즈 구성
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(32))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        // 섹션 구성
        let section = NSCollectionLayoutSection(group: group)

        // 섹션의 헤더 뷰 구성
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(24))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [header]

        // 섹션 내 여백 설정
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 20, trailing: 0)
        
        // 섹션 내 아이템 간 최소 간격 설정
        section.interGroupSpacing = 8

        return section
    }
    
    func makeCategorySheetHeaderSectionLayout(from item: CategorySheetItem) -> NSCollectionLayoutSection? {
        let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1)), subitems: .init(repeating: .init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1))), count: 1))
        
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(40)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .leading)

        let section: NSCollectionLayoutSection = .init(group: group)
        section.boundarySupplementaryItems = [header]
        section.contentInsets = .init(top: 0, leading: UI.sectionMargin.left, bottom: 0, trailing: UI.sectionMargin.right)

        return section
    }
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
            $0.collectionViewLayout = layer
            $0.showsVerticalScrollIndicator = false
            $0.backgroundColor = R.Color.white
            $0.isScrollEnabled = true
            $0.isHidden = false
            $0.register(CategorySelectCell.self, forCellWithReuseIdentifier: "CategorySelectCell")
            $0.register(CategorySelectHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CategorySelectHeaderCell")
        }
        
        emptyStackView = emptyStackView.then {
            $0.axis = .vertical
            $0.distribution = .fill
            $0.spacing = 16
            $0.isHidden = true
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

extension CategorySheetViewController: UICollectionViewDelegateFlowLayout {
    // 지정된 섹션의 헤더뷰의 크기를 반환하는 메서드. 크기를 지정하지 않으면 화면에 보이지 않습니다.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width , height: 24)
    }

    // 지정된 섹션의 여백을 반환하는 메서드.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 0, bottom: 20, right: 0)
    }

    // FIXME: - flowlayout이 동작안할 경우 이쪽 부분 다시 ㄱㄱ, Cell의 실제 넓이가 안맞는 거 같음
    // 지정된 섹션의 셀 사이의 최소간격을 반환하는 메서드.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }

    // 지정된 섹션의 열 사이 간격 최소 간격을 반환하는 메서드. scrollDirection이 horizontal이면 수직이 행이 되고 vertical이면 수평이 행이 된다.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }

    // 지정된 셀의 크기를 반환하는 메서드
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 셀의 내용이 될 텍스트
        
        let text = reactor?.currentState.categoryList[indexPath.section].lowwer[indexPath.item].title ?? "default text"

        // 설정할 최대 너비
        let maxWidth = collectionView.bounds.width
        // 여기서는 컬렉션 뷰의 너비를 최대 너비로 사용했지만,
        // 여러분의 레이아웃에 따라 다를 수 있습니다.
        
        // 레이블의 패딩이나 마진을 조정
        let labelInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 30)
        
        // 텍스트에 기반한 레이블의 크기를 계산합니다.
        let size = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        let options: NSStringDrawingOptions = [.usesFontLeading, .usesLineFragmentOrigin]
        let attributes = [NSAttributedString.Key.font: R.Font.body3]
        
        let estimatedFrame = NSString(string: text).boundingRect(with: size, options: options, attributes: attributes, context: nil)
        
        // 최종 셀의 너비는 레이블의 계산된 너비 + 좌우 패딩
        let cellWidth = ceil(estimatedFrame.width + labelInsets.left + labelInsets.right)
        
        // 최종 셀의 높이는 레이블의 계산된 높이 + 상하 패딩 (여기서는 예시로 셀의 높이를 고정값으로 설정)
        let cellHeight: CGFloat = 32
        
        // 최종 셀 사이즈 반환
        return CGSize(width: cellWidth + 2, height: cellHeight)
    }
}
