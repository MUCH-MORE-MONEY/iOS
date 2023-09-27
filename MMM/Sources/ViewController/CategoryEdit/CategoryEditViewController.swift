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
		static let cellHeightMargin: CGFloat = 24
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
//		dataSource.moveItem = { dataSource, sourceIndexPath, destinationIndexPath in
//			guard sourceIndexPath.section == destinationIndexPath.section else { return }
//			let sourceItem = dataSource[sourceIndexPath.section].items[sourceIndexPath.row]
//
////			reactor.action.onNext(.dragAndDrop(sourceIndexPath, destinationIndexPath, sourceItem))
//
//			// dataSource 이동
//	//		dataSource.remove(at: sourceIndexPath.item)
//	//		dataSource.insert(sourceItem, at: destinationIndexPath.item)
//			
//			// UI에 반영
////			self.collectionView.deleteItems(at: [sourceIndexPath])
////			self.collectionView.insertItems(at: [destinationIndexPath])
//		}
//		
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
////					guard
////						let startIndexPath = startIndexPath,
////						let moveIndexPath = moveIndexPath,
////						startIndexPath.section == moveIndexPath.section
////					else { break }
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
			.filter { !$0.1.isEmpty }
			.subscribe(onNext: { this, sections in
				guard !sections.isEmpty else { return }
				
				//				DispatchQueue.main.async {
				for item in sections {
					print(item.model.header)
					for i in item.items {
						print(i.item)
					}
					print()
				}
				this.dataSource.setSections(sections)
				if let layout = self.layout {
//					this.collectionView.setCollectionViewLayout(<#T##layout: UICollectionViewLayout##UICollectionViewLayout#>, animated: <#T##Bool#>)
				} else {
					self.layout = self.makeLayout(sections: sections)
				}
				let lay = this.makeLayout(sections: sections)
				print("lay", self.layout)
				this.collectionView.collectionViewLayout.invalidateLayout()
				this.collectionView.collectionViewLayout = self.layout!
				this.collectionView.reloadData()
				print("-------------------------")
				//				}
			})
			.disposed(by: disposeBag)
		
		reactor.state
			.compactMap { $0.nextEditScreen }
			.subscribe(onNext: { [weak self] categoryEdit in
				self?.willPresentViewController(categoryEdit: categoryEdit)
			})
			.disposed(by: disposeBag)

	}
}
//MARK: - Action
extension CategoryEditViewController {
	// Section별 Cell Layout
	func makeLayout(sections: [CategoryEditSectionModel]) -> UICollectionViewCompositionalLayout {
		return UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
			return self?.makeCategorySectionLayout(from: sections[sectionIndex].items)
		}
	}
	
	func makeCategorySectionLayout(from items: [CategoryEditItem]) -> NSCollectionLayoutSection {
		var layoutItems: [NSCollectionLayoutItem] = []
		
		items.forEach({ item in
			switch item {
			case .base:
				layoutItems.append(NSCollectionLayoutItem.init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(UI.cellHeightMargin))))
			}
		})

		let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: layoutItems)
		group.interItemSpacing = .fixed(UI.cellSpacingMargin)
		group.contentInsets = .init(top: 0, leading: 136, bottom: 0, trailing: 0)
		
		let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(0.395), heightDimension: .absolute(UI.cellHeightMargin)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
		header.contentInsets = .init(top: UI.cellHeightMargin, leading: 0, bottom: 0, trailing: 0)
		
		let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(60)), elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
		
		let section: NSCollectionLayoutSection = .init(group: group)
		section.boundarySupplementaryItems = [.init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)]
		section.boundarySupplementaryItems = [header, footer]
		section.contentInsets = .init(top: UI.sectionMargin.top, leading: UI.sectionMargin.left, bottom: UI.sectionMargin.bottom, trailing: UI.sectionMargin.right)
		
		return section
	}
	
//	private func cellForItemAt(at indexPath: IndexPath?) -> UICollectionViewCell? {
//		guard let indexPath = indexPath else {
//			return nil
//		}
//		return collectionView.cellForItem(at: indexPath)
//	}
	
	private func willPresentViewController(categoryEdit: CategoryEdit) {
		guard let reactor = self.reactor else { return }
		
		let vc = CategoryEditBottomSheetViewController(title: "카테고리 수정하기", categoryEdit: categoryEdit, height: 174)
		vc.reactor = CategoryEditBottomSheetReactor(provider: reactor.provider)

		self.present(vc, animated: true, completion: nil)
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
// MARK: UICollectionView Drag Delegate
extension CategoryEditViewController: UICollectionViewDragDelegate {
	func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
		let itemProvider = NSItemProvider()
		let dragItem = UIDragItem(itemProvider: itemProvider)
		
		// 2. itemsForBeginning 메소드 안에서 UIDragItem의 배열들을 리턴하게 되는데, UIDragItem안에 previewProvider를 사용하여 프리뷰의 정보 세팅이 가능
		guard
			let targetView = (collectionView.cellForItem(at: indexPath) as? CategoryEditCollectionViewCell)?.contentView,
			let dragPreview = targetView.snapshotView(afterScreenUpdates: false)
		else {
			return [UIDragItem(itemProvider: NSItemProvider())]
		}
		
		// 3. 색상 변경
		dragPreview.backgroundColor = R.Color.gray900
		
		// 4. previewProvider의 값에 보여줄 뷰와 그 뷰의 rect, cornerRadius값을 설정
		let previewParameters = UIDragPreviewParameters()
		previewParameters.visiblePath = UIBezierPath(
			roundedRect: dragPreview.bounds,
			cornerRadius: targetView.layer.cornerRadius
		)
		
		dragItem.previewProvider = { () -> UIDragPreview? in
			UIDragPreview(view: dragPreview, parameters: previewParameters)
		}
		
		return [dragItem]
	}
	
	func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
		return true
	}
}
// MARK : UICollectionView Drop Delegate
extension CategoryEditViewController: UICollectionViewDropDelegate {
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
			let sourceIndexPath = sourceItem.sourceIndexPath,
			sourceIndexPath.section == destinationIndexPath.section
		else { return }

		collectionView.performBatchUpdates { [weak self] in
			self?.move(sourceIndexPath: sourceIndexPath, destinationIndexPath: destinationIndexPath)
		} completion: { finish in
			coordinator.drop(sourceItem.dragItem, toItemAt: destinationIndexPath)
		}
	}
	
	private func move(sourceIndexPath: IndexPath, destinationIndexPath: IndexPath) {
		let sourceItem = dataSource[sourceIndexPath.section].items[sourceIndexPath.row]
		let newIndexPath = IndexPath(row: destinationIndexPath.row + 1, section: destinationIndexPath.section)

		// UI에 반영
		collectionView.deleteItems(at: [sourceIndexPath])
		collectionView.insertItems(at: [destinationIndexPath])

		// dataSource 이동
//		reactor?.action.onNext(.dragAndDrop(sourceIndexPath, destinationIndexPath, sourceItem))
	}
}
