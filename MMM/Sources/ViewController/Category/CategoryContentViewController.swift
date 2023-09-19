//
//  CategoryContentViewController.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/15.
//

import Then
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import RxDataSources

final class CategoryContentViewController: BaseViewController, View {
	typealias Reactor = CategoryReactor
	typealias DataSource = RxCollectionViewSectionedReloadDataSource<CategorySectionModel> // SectionModelType 채택
	
	// MARK: - Constants
	private enum UI {
		static let topMargin: CGFloat = 0
		static let cellWidthMargin: CGFloat = 48
		static let cellTopMargin: CGFloat = 8
		static let categoryCellHeight: CGFloat = 165
		static let headerHeight: CGFloat = 60
		static let sectionMargin: UIEdgeInsets = .init(top: 0, left: 24, bottom: 48, right: 24)
	}
	
	// MARK: - Properties
	private lazy var dataSource = DataSource { [weak self] _, collectionView, indexPath, item -> UICollectionViewCell in
		guard let reactor = self?.reactor else { return .init() }
		
		switch item {
		case let .base(cellReactor):
			guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CategoryCollectionViewCell.self), for: indexPath) as? CategoryCollectionViewCell else { return .init() }
			
			cell.reactor = cellReactor // reactor 주입
			
			return cell
		}
	} configureSupplementaryView: { [weak self] dataSource, collectionView, _, indexPath -> UICollectionReusableView in
		guard let thisReactor = self?.reactor else { return .init() }

		switch dataSource[indexPath.section].model {
		case .base:
			guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: String(describing: CategorySectionHeader.self), for: indexPath) as? CategorySectionHeader else { return .init() }
			return header
		}
	}
	
	// MARK: - UI Components
	private lazy var refreshControl: UIRefreshControl = .init()
	private lazy var collectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
	func bind(reactor: CategoryReactor) {
		bindState(reactor)
		bindAction(reactor)
	}
}
//MARK: - Bind
extension CategoryContentViewController {
	// MARK: 데이터 변경 요청 및 버튼 클릭시 요청 로직(View -> Reactor)
	private func bindAction(_ reactor: CategoryReactor) {
		// CollectionView cell select
		Observable.zip(
			collectionView.rx.itemSelected,
			collectionView.rx.modelSelected(type(of: dataSource).Section.Item.self)
		)
		.map { .selectCell($0, $1) }
		.bind(to: reactor.action)
		.disposed(by: disposeBag)
		
		// Refresh Data
		refreshControl.rx.controlEvent(.valueChanged)
			.map { .fetch }
			.bind(to: reactor.action)
			.disposed(by: disposeBag)
	}
	
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: CategoryReactor) {
		// Section별 items 전달
		reactor.state
			.map(\.paySections)
			.withUnretained(self)
			.subscribe(onNext: { this, sections in
				guard !sections.isEmpty else { return }
				
				this.collectionView.refreshControl?.endRefreshing()
				this.dataSource.setSections(sections)
				this.collectionView.collectionViewLayout = this.makeLayout(sections: sections)
				this.collectionView.reloadData()
			})
			.disposed(by: disposeBag)
	}
}
//MARK: - Action
extension CategoryContentViewController {
	// Section별 Cell Layout
	func makeLayout(sections: [CategorySectionModel]) -> UICollectionViewCompositionalLayout {
		let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
			switch sections[sectionIndex].model {
			case let .base(items):
				return self?.makeCategorySectionLayout(from: items)
			}
		}
		
		return layout
	}
	
	func makeCategorySectionLayout(from items: [CategoryItem]) -> NSCollectionLayoutSection {
		var layoutItems: [NSCollectionLayoutItem] = []
		
		items.forEach({ item in
			switch item {
			case .base:
				layoutItems.append(.init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(120))))
			}
		})
		
		let layoutGroup = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: layoutItems)
		layoutGroup.interItemSpacing = .fixed(20)
		layoutGroup.contentInsets = .init(top: 0, leading: 24, bottom: 0, trailing: 24)
		
		let layoutSection: NSCollectionLayoutSection = .init(group: layoutGroup)
		layoutSection.boundarySupplementaryItems = [.init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)]
		
		return layoutSection
	}
}
//MARK: - Attribute & Hierarchy & Layouts
extension CategoryContentViewController {
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()
		
		view.backgroundColor = R.Color.gray900

		refreshControl = refreshControl.then {
			$0.transform = CGAffineTransformMakeScale(0.5, 0.5)
		}
		
		collectionView = collectionView.then {
			$0.dataSource = dataSource
			$0.refreshControl = refreshControl
			$0.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: CategoryCollectionViewCell.self))
			$0.register(CategorySectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: String(describing: CategorySectionHeader.self))
			$0.backgroundColor = R.Color.gray900
		}
	}
	
	override func setHierarchy() {
		super.setHierarchy()
		
		view.addSubviews(collectionView)
	}
	
	override func setLayout() {
		super.setLayout()
		
		collectionView.snp.makeConstraints {
			$0.top.leading.trailing.bottom.equalToSuperview()
		}
	}
}
// MARK: - UICollectionView DelegateFlowLayout
extension CategoryContentViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		return CGSize(width: collectionView.frame.width, height: UI.headerHeight)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UI.sectionMargin
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return UI.cellTopMargin
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return UI.cellTopMargin
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		switch dataSource[indexPath.section].items[indexPath.row] {
		case .base:
			return CGSize(width: collectionView.frame.width - UI.cellWidthMargin, height: UI.categoryCellHeight)
		}
	}
}
