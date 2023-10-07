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

// 상속하지 않으려면 final 꼭 붙이기
final class CategoryContentViewController: BaseViewController, View {
	typealias Reactor = CategoryMainReactor
	typealias DataSource = RxCollectionViewSectionedReloadDataSource<CategoryMainSectionModel> // SectionModelType 채택
	
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
			guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CategoryCollectionViewCell.self), for: indexPath) as? CategoryCollectionViewCell else { return .init() }
			
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
				guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: String(describing: CategorySectionHeader.self), for: indexPath) as? CategorySectionHeader else { return .init() }
				let sectionInfo = dataSource.sectionModels[indexPath.section].model.header
				
				header.setDate(category: sectionInfo, type: self?.mode.rawValue ?? "01")
				return header
			}
		} else {
			guard let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: String(describing: CategorySectionFooter.self), for: indexPath) as? CategorySectionFooter else { return .init() }
			
			let count = self?.mode == .pay ? thisReactor.currentState.paySections.count : thisReactor.currentState.earnSections.count
			footer.setData(isLast: indexPath.section == count - 1) // 마지막 섹션은 separator 숨기기
			return footer
		}
	}
	
	// MARK: - UI Components
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
	
	func bind(reactor: CategoryMainReactor) {
		bindState(reactor)
		bindAction(reactor)
	}
}
//MARK: - Bind
extension CategoryContentViewController {
	// MARK: 데이터 변경 요청 및 버튼 클릭시 요청 로직(View -> Reactor)
	private func bindAction(_ reactor: CategoryMainReactor) {
		// CollectionView cell select
		Observable.zip(
			collectionView.rx.itemSelected,
			collectionView.rx.modelSelected(type(of: dataSource).Section.Item.self)
		)
		.map { .selectCell($0, $1) }
		.bind(to: reactor.action)
		.disposed(by: disposeBag)
	}
	
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: CategoryMainReactor) {
		// 지출 - Section별 items 전달
		reactor.state
			.map( mode == .earn ? \.earnSections : \.paySections)
			.withUnretained(self)
			.filter { !$0.1.isEmpty }
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
extension CategoryContentViewController {
	// Section별 Cell Layout
	func makeLayout(sections: [CategoryMainSectionModel]) -> UICollectionViewCompositionalLayout {
		let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
			return self?.makeCategorySectionLayout(from: sections[sectionIndex].items)
		}
		
		return layout
	}
	
	func makeCategorySectionLayout(from items: [CategoryMainItem]) -> NSCollectionLayoutSection {
		var layoutItems: [NSCollectionLayoutItem] = []
		
		items.forEach({ item in
			switch item {
			case .base:
				layoutItems.append(.init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(UI.cellHeightMargin))))
			}
		})
		
		let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: layoutItems)
		group.interItemSpacing = .fixed(UI.cellSpacingMargin)
		group.contentInsets = .init(top: 0, leading: 192, bottom: 0, trailing: 0)
		
		let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(0.55), heightDimension: .absolute(UI.cellHeightMargin)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
		header.contentInsets = .init(top: UI.cellHeightMargin, leading: 0, bottom: 0, trailing: 0)

		let separtor = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(1)), elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
		
		let section: NSCollectionLayoutSection = .init(group: group)
		section.boundarySupplementaryItems = [.init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)]
		section.boundarySupplementaryItems = [header, separtor]
		section.contentInsets = .init(top: UI.sectionMargin.top, leading: UI.sectionMargin.left, bottom: UI.sectionMargin.bottom, trailing: UI.sectionMargin.right)
		
		return section
	}
}
//MARK: - Attribute & Hierarchy & Layouts
extension CategoryContentViewController {
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()
		
		view.backgroundColor = R.Color.gray900
		
		collectionView = collectionView.then {
			$0.dataSource = dataSource
			$0.register(CategoryCollectionViewCell.self)
			$0.register(CategorySectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
			$0.register(CategorySectionFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter)
			$0.showsVerticalScrollIndicator = false
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
	// 지정된 섹션의 헤더뷰의 크기를 반환하는 메서드. 크기를 지정하지 않으면 화면에 보이지 않습니다.
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		return CGSize(width: (collectionView.frame.width) / 2, height: UI.headerHeight)
	}
	
	// 지정된 섹션의 여백을 반환하는 메서드.
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UI.sectionMargin
	}
	
	// 지정된 섹션의 셀 사이의 최소간격을 반환하는 메서드.
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return UI.cellSpacingMargin
	}
	
	// 지정된 섹션의 행 사이 간격 최소 간격을 반환하는 메서드. scrollDirection이 horizontal이면 수직이 행이 되고 vertical이면 수평이 행이 된다.
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return UI.cellSpacingMargin
	}
	
	// 지정된 셀의 크기를 반환하는 메서드
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		switch dataSource[indexPath.section].items[indexPath.row] {
		case .base:
			return CGSize(width: collectionView.frame.width - UI.cellWidthMargin, height: UI.categoryCellHeight)
		}
	}
}
