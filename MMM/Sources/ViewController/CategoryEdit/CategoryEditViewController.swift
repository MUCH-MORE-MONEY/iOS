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
import RxGesture

// 상속하지 않으려면 final 꼭 붙이기
final class CategoryEditViewController: BaseViewControllerWithNav, View {
	typealias Reactor = CategoryEditReactor
	typealias DataSource = RxCollectionViewSectionedReloadDataSource<CategoryEditSectionModel> // SectionModelType 채택
	public typealias MoveItem = (CollectionViewSectionedDataSource<CategoryEditSectionModel>, _ sourceIndexPath:IndexPath, _ destinationIndexPath:IndexPath) -> Void
	public typealias CanMoveItemAtIndexPath = (CollectionViewSectionedDataSource<CategoryEditSectionModel>, IndexPath) -> Bool

	// MARK: - Constants
	private enum UI {
		static let topMargin: CGFloat = 0
		static let cellSpacingMargin: CGFloat = 16
		static let cellHeightMargin: CGFloat = 40 // spacing(16)도 더하기
		static let categoryCellHeight: CGFloat = 165
		static let headerHeight: CGFloat = 60
		static let sectionMargin: UIEdgeInsets = .init(top: 0, left: 24, bottom: 8, right: 24)
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
			
			return cell
		case let .header(cellReactor), let .footer(cellReactor):
			return .init()
		}
	} configureSupplementaryView: { [weak self] dataSource, collectionView, kind, indexPath -> UICollectionReusableView in
		guard let thisReactor = self?.reactor else { return .init() }
		
		if kind == UICollectionView.elementKindSectionHeader {
			switch dataSource[indexPath.section].model {
			case .header:
				guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CategoryEditSectionGlobalHeader.className, for: indexPath) as? CategoryEditSectionGlobalHeader else { return .init() }
				return header
			case .base:
				guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CategoryEditSectionHeader.className, for: indexPath) as? CategoryEditSectionHeader else { return .init() }
				let sectionInfo = dataSource.sectionModels[indexPath.section].model.header
				
				header.setDate(title: "\(sectionInfo.title)")
				return header
			case .footer:
				return .init()
			}
		} else {
			switch dataSource[indexPath.section].model {
			case .header:
				return .init()
			case .base:
				guard let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: CategoryEditSectionFooter.className, for: indexPath) as? CategoryEditSectionFooter else { return .init() }
				let sectionInfo = dataSource.sectionModels[indexPath.section].model.header
				
				let count = thisReactor.currentState.headers.count
				
				// 마지막 섹션은 separator 숨기기
				// Global Header로 인한 section수 1개 증가
				footer.setData(categoryHeader: sectionInfo, isLast: indexPath.section == count)
				footer.reactor = thisReactor
				
				return footer
			case .footer:
				guard let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: CategoryEditSectionGlobalFooter.className, for: indexPath) as? CategoryEditSectionGlobalFooter else { return .init() }
				
				footer.reactor = thisReactor
				
				return footer
			}
		}
	}
	
	// MARK: - UI Components
	private lazy var titleStackView = UIStackView()
	private lazy var titleImageView = UIImageView()
	private lazy var titleLabel = UILabel()
	private lazy var checkButton = UIButton()
	private lazy var collectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
	private var startIndexPath: IndexPath?
	private var layout: UICollectionViewCompositionalLayout?
	
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
		
//		dataSource.canMoveItemAtIndexPath = { dataSource, indexPath in
//			return true
//		}
//
		
		// 셀이 이동되었을때
//		dataSource.moveItem = { dataSource, sourceIndexPath, destinationIndexPath in
//			reactor.action.onNext(.dragAndDrop(sourceIndexPath, destinationIndexPath))
//		}
		
//		collectionView.rx.longPressGesture()
//			.subscribe(onNext: { [weak self] moveGesture in
//				guard let self = self else { return }
//				let moveIndexPath = collectionView.indexPathForItem(at: moveGesture.location(in: collectionView))
//				
//				switch moveGesture.state {
//				case .began:
//					guard let moveIndexPath = moveIndexPath else {
//						break
//					}
//					startIndexPath = moveIndexPath
//					collectionView.beginInteractiveMovementForItem(at: moveIndexPath)
//				case .changed:
//					guard
//						let startIndexPath = startIndexPath,
//						let moveIndexPath = moveIndexPath,
//						startIndexPath.section == moveIndexPath.section
//					else { break }
//					collectionView.updateInteractiveMovementTargetPosition(moveGesture.location(in: collectionView))
//				case .ended:
////					guard
////						let startIndexPath = startIndexPath,
////						let moveIndexPath = moveIndexPath,
////						startIndexPath.section == moveIndexPath.section
////					else { break }
//					collectionView.endInteractiveMovement()
//					break
//				default:
//					collectionView.cancelInteractiveMovement()
//				}
//			})
//			.disposed(by: disposeBag)
	}
	
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: CategoryEditReactor) {
		// 지출 - Section별 items 전달
		reactor.state
			.map { $0.sections }
			.withUnretained(self)
			.distinctUntilChanged { $0.1 }
			.subscribe(onNext: { this, sections in
				guard !sections.isEmpty else { return }
				this.dataSource.setSections(sections)
				this.collectionView.collectionViewLayout = this.makeLayout(sections: sections)
				this.collectionView.reloadData()
			})
			.disposed(by: disposeBag)
		
		reactor.state
			.compactMap { $0.nextEditScreen }
			.bind(onNext: willPresentEditViewController)
			.disposed(by: disposeBag)

		reactor.state
			.compactMap { $0.nextAddScreen }
			.bind(onNext: willPresentAddViewController)
			.disposed(by: disposeBag)
		
		// 카테고리 유형 편집
		reactor.state
			.map { $0.nextUpperEditScreen }
			.distinctUntilChanged() // 중복값 무시
			.filter { $0 } // true 일때만
			.bind(onNext: willPushUpperEditViewController)
			.disposed(by: disposeBag)
	}
}
//MARK: - Action
extension CategoryEditViewController {
	// Section별 Cell Layout
	func makeLayout(sections: [CategoryEditSectionModel]) -> UICollectionViewCompositionalLayout {
		return UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
			switch sections[sectionIndex].model {
			case .header:
				return self?.makeHeaderSectionLayout()
			case .base:
				return self?.makeCategorySectionLayout(from: sections[sectionIndex].items)
			case .footer:
				return self?.makeFooterSectionLayout()
			}
		}
	}
	
	func makeCategorySectionLayout(from items: [CategoryEditItem]) -> NSCollectionLayoutSection {
		let isEmpty = items.isEmpty // Item이 없을 경우
		var layoutItems: [NSCollectionLayoutItem] = []
		
		items.forEach({ item in
			switch item {
			case .base:
				layoutItems.append(NSCollectionLayoutItem.init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(UI.cellHeightMargin))))
			default:
				break
			}
		})
		
		let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: isEmpty ? .init(repeating: .init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(UI.cellHeightMargin))), count: 1) : layoutItems)
		group.contentInsets = .init(top: 0, leading: 136, bottom: 0, trailing: 0)
		
		let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(0.395), heightDimension: .absolute(UI.cellHeightMargin + (isEmpty ? 6 : 0))), elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
		header.contentInsets = .init(top: isEmpty ? 0 : UI.cellHeightMargin - 6, leading: 0, bottom: 0, trailing: 0)
		
		let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(60)), elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
		
		let section: NSCollectionLayoutSection = .init(group: group)
		section.boundarySupplementaryItems = [header, footer]
		section.contentInsets = .init(top: UI.sectionMargin.top, leading: UI.sectionMargin.left, bottom: UI.sectionMargin.bottom, trailing: UI.sectionMargin.right)
		
		return section
	}
	
	func makeHeaderSectionLayout() -> NSCollectionLayoutSection {
		let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0)), subitems: .init(repeating: .init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))), count: 1))
		
		let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(40)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)

		let section: NSCollectionLayoutSection = .init(group: group)
		section.boundarySupplementaryItems = [header]
		section.contentInsets = .init(top: 0, leading: UI.sectionMargin.left, bottom: 0, trailing: UI.sectionMargin.right)
		
		return section
	}
	
	func makeFooterSectionLayout() -> NSCollectionLayoutSection {
		let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0)), subitems: .init(repeating: .init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(UI.cellHeightMargin))), count: 1))
		
		let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(56)), elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)

		let section: NSCollectionLayoutSection = .init(group: group)
		section.boundarySupplementaryItems = [footer]
		section.contentInsets = .init(top: UI.sectionMargin.top, leading: UI.sectionMargin.left, bottom: UI.sectionMargin.bottom, trailing: UI.sectionMargin.right)
		
		return section
	}
	
	private func willPresentEditViewController(categoryEdit: CategoryEdit) {
		guard let reactor = self.reactor else { return }
		
		let vc = CategoryEditBottomSheetViewController(title: "카테고리 수정하기", categoryEdit: categoryEdit, height: 174)
		vc.reactor = CategoryEditBottomSheetReactor(provider: reactor.provider)

		self.present(vc, animated: true, completion: nil)
	}
	
	private func willPresentAddViewController(categoryHeader: CategoryHeader) {
		guard let reactor = self.reactor else { return }
		
		let vc = CategoryAddBottomSheetViewController(title: "카테고리 추가하기", categoryHeader: categoryHeader, addId: reactor.currentState.addId - 1, height: 174)
		vc.reactor = CategoryEditBottomSheetReactor(provider: reactor.provider)

		self.present(vc, animated: true, completion: nil)
	}
	
	private func willPushUpperEditViewController(isPush: Bool) {
		guard let reactor = self.reactor else { return }
		
		let vc = CategoryUpperEditViewController()
		vc.reactor = reactor
		
		navigationController?.pushViewController(vc, animated: true)
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
			$0.dragDelegate = self
			$0.dropDelegate = self
			$0.dataSource = dataSource
			$0.register(CategoryEditCollectionViewCell.self)
			$0.register(CategoryEditSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
			$0.register(CategoryEditSectionFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter)
			// Global Header
			$0.register(CategoryEditSectionGlobalHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
			// Global Footer
			$0.register(CategoryEditSectionGlobalFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter)
			$0.showsVerticalScrollIndicator = false
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
// MARK: - UICollectionView Drag Delegate
extension CategoryEditViewController: UICollectionViewDragDelegate {
	func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
		return [UIDragItem(itemProvider: NSItemProvider())]
	}
}
// MARK: - UICollectionView Drop Delegate
extension CategoryEditViewController: UICollectionViewDropDelegate {
	func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
		return true
	}
	
	// drag가 활성화 되어 있는경우에만 drop이 동작하도록 구현
	// drag없이 drop이 동작할 수 없도록 하는 메소드
	func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
		guard collectionView.hasActiveDrag else {
			return UICollectionViewDropProposal(operation: .forbidden)
		}
		
		return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
	}
	
	func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
		var destinationIndexPath: IndexPath
		
		if let indexPath = coordinator.destinationIndexPath {
			destinationIndexPath = indexPath
		} else {
			let row = collectionView.numberOfItems(inSection: 0)
			destinationIndexPath = IndexPath(item: row - 1, section: 0)
		}
		guard coordinator.proposal.operation == .move else { return }
		move(coordinator: coordinator, destinationIndexPath: destinationIndexPath, collectionView: collectionView)
	}
	
	private func move(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView) {
		guard
			let sourceItem = coordinator.items.first,
			let sourceIndexPath = sourceItem.sourceIndexPath
		else { return }

		collectionView.performBatchUpdates { [weak self] in
			self?.move(sourceIndexPath: sourceIndexPath, destinationIndexPath: destinationIndexPath, collectionView: collectionView)
		} completion: { finish in
			coordinator.drop(sourceItem.dragItem, toItemAt: destinationIndexPath)
			// 끝난뒤 변경
			self.reactor?.action.onNext(.dragAndDrop(sourceIndexPath, destinationIndexPath))
		}
	}
	
	private func move(sourceIndexPath: IndexPath, destinationIndexPath: IndexPath, collectionView: UICollectionView) {
		// dataSource에 반영
		dataSource.collectionView(collectionView, moveItemAt: sourceIndexPath, to: destinationIndexPath)

		// UI에 반영
		collectionView.deleteItems(at: [sourceIndexPath])
		collectionView.insertItems(at: [destinationIndexPath])
	}
}
