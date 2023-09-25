//
//  CategoryEditViewController.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/24.
//

import Then
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import RxDataSources

// 상속하지 않으려면 final 꼭 붙이기
final class CategoryEditViewController: BaseViewControllerWithNav, View {
	typealias Reactor = CategoryEditReactor
	typealias DataSource = RxCollectionViewSectionedReloadDataSource<CategoryEditSectionModel> // SectionModelType 채택
	
	// MARK: - Constants
	private enum UI {
		static let topMargin: CGFloat = 0
		static let cellWidthMargin: CGFloat = 48
		static let cellSpacingMargin: CGFloat = 16
		static let categoryCellHeight: CGFloat = 165
		static let headerHeight: CGFloat = 60
		static let sectionMargin: UIEdgeInsets = .init(top: 16, left: 24, bottom: 16, right: 24)
	}
	
	// MARK: - Constants
	enum Mode: String {
		case pay = "01"
		case earn = "02"
	}
	
	// MARK: - Properties
	private let mode: Mode
	private lazy var dataSource = DataSource { [weak self] _, collectionView, indexPath, item -> UICollectionViewCell in
		guard let reactor = self?.reactor else { return .init() }
		
		switch item {
		case let .base(cellReactor):
			guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CategoryEditCollectionViewCell.self), for: indexPath) as? CategoryEditCollectionViewCell else { return .init() }
			
			cell.reactor = cellReactor // reactor 주입
			
			let backgroundView = UIView()
			backgroundView.backgroundColor = R.Color.gray400.withAlphaComponent(0.3)
			cell.selectedBackgroundView = backgroundView
			
			return cell
		}
	} configureSupplementaryView: { [weak self] dataSource, collectionView, kind, indexPath -> UICollectionReusableView in
		guard let thisReactor = self?.reactor else { return .init() }
		
		if kind == UICollectionView.elementKindSectionHeader {
			switch dataSource[indexPath.section].model {
			case .base:
				guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: String(describing: CategoryEditSectionHeader.self), for: indexPath) as? CategoryEditSectionHeader else { return .init() }
				let sectionInfo = dataSource.sectionModels[indexPath.section].model.header
				
				header.setDate(title: "\(sectionInfo.title)")
				return header
			}
		} else {
			guard let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: String(describing: CategoryEditSectionFooter.self), for: indexPath) as? CategoryEditSectionFooter else { return .init() }
			
			let count = thisReactor.currentState.headers.count
			footer.setData(isLast: indexPath.section == count - 1) // 마지막 섹션은 separator 숨기기
			return footer
		}
	}
	
	// MARK: - UI Components
	private lazy var titleStackView = UIStackView()
	private lazy var titleImageView = UIImageView()
	private lazy var titleLabel = UILabel()
	private lazy var checkButton = UIButton()
	private lazy var collectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
	
	init(mode: Mode) {
		self.mode = mode
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
	
	func bind(reactor: CategoryEditReactor) {
		bindState(reactor)
		bindAction(reactor)
	}
}
//MARK: - Bind
extension CategoryEditViewController {
	// MARK: 데이터 변경 요청 및 버튼 클릭시 요청 로직(View -> Reactor)
	private func bindAction(_ reactor: CategoryEditReactor) {
		checkButton.rx.tap
			.subscribe(onNext: {
				self.navigationController?.popViewController(animated: true)
			}).disposed(by: disposeBag)
	}
	
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: CategoryEditReactor) {
		// 지출 - Section별 items 전달
		reactor.state
			.map { $0.sections }
			.withUnretained(self)
			.subscribe(onNext: { this, sections in
				guard !sections.isEmpty else { return }
				
				this.dataSource.setSections(sections)
				this.collectionView.collectionViewLayout = this.makeLayout(sections: sections)
				this.collectionView.reloadData()
			})
			.disposed(by: disposeBag)
	}
}
//MARK: - Action
extension CategoryEditViewController {
	// Section별 Cell Layout
	func makeLayout(sections: [CategoryEditSectionModel]) -> UICollectionViewCompositionalLayout {
		let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
			return self?.makeCategorySectionLayout(from: sections[sectionIndex].items)
		}
		
		return layout
	}
	
	func makeCategorySectionLayout(from items: [CategoryEditItem]) -> NSCollectionLayoutSection {
		var layoutItems: [NSCollectionLayoutItem] = []
		
		items.forEach({ item in
			switch item {
			case .base:
				layoutItems.append(.init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(24))))
			}
		})
		
		let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: layoutItems)
		group.interItemSpacing = .fixed(UI.cellSpacingMargin)
		group.contentInsets = .init(top: 0, leading: 136, bottom: 0, trailing: 0)
		
		let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(0.1)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
		
		let separtor = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(1)), elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
		
		let section: NSCollectionLayoutSection = .init(group: group)
		section.boundarySupplementaryItems = [.init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)]
		section.boundarySupplementaryItems = [header, separtor]
		section.contentInsets = .init(top: UI.sectionMargin.top, leading: UI.sectionMargin.left, bottom: UI.sectionMargin.bottom, trailing: UI.sectionMargin.right)
		
		return section
	}
}
//MARK: - Attribute & Hierarchy & Layouts
extension CategoryEditViewController {
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()
		
		view.backgroundColor = R.Color.gray900
		navigationItem.titleView = titleStackView
		navigationItem.rightBarButtonItem = UIBarButtonItem(customView: checkButton)

		// Navigation Title View
		titleStackView = titleStackView.then {
			$0.axis = .horizontal
			$0.spacing = 4
		}
		
		titleImageView = titleImageView.then {
			$0.image = mode == .pay ? R.Icon.minus16 : R.Icon.plus16
			$0.contentMode = .scaleAspectFit
		}
		
		titleLabel = titleLabel.then {
			$0.text = (mode == .pay ? "지출" : "수입") + " 카테고리 편집"
			$0.font = R.Font.title3
			$0.textColor = R.Color.white
			$0.textAlignment = .left
		}
		
		// Navigation Bar Right Button
		checkButton = checkButton.then {
			$0.setTitle("확인", for: .normal)
			$0.setTitleColor(R.Color.white.withAlphaComponent(0.7), for: .highlighted)
			$0.titleLabel?.font = R.Font.body1
		}
		
		collectionView = collectionView.then {
			$0.dataSource = dataSource
			$0.register(CategoryEditCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: CategoryEditCollectionViewCell.self))
			$0.register(CategoryEditSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: String(describing: CategoryEditSectionHeader.self))
			$0.register(CategoryEditSectionFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: String(describing: CategoryEditSectionFooter.self))
			$0.showsHorizontalScrollIndicator = false
			$0.backgroundColor = R.Color.gray900
		}
	}
	
	override func setHierarchy() {
		super.setHierarchy()
		
		titleStackView.addArrangedSubviews(titleImageView, titleLabel)
		view.addSubviews(collectionView)
	}
	
	override func setLayout() {
		super.setLayout()
		
		collectionView.snp.makeConstraints {
			$0.top.leading.trailing.bottom.equalToSuperview()
		}
	}
}
