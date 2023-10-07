//
//  CategoryEditUpperViewController.swift
//  MMM
//
//  Created by geonhyeong on 10/7/23.
//

import Then
import SnapKit
import RxSwift
import ReactorKit

// 상속하지 않으려면 final 꼭 붙이기
final class CategoryEditUpperViewController: BaseViewControllerWithNav, View {
	typealias Reactor = CategoryEditUpperReactor

	// MARK: - Constants
	private enum UI {
	}
	
	// MARK: - Properties
	
	// MARK: - UI Components
	private lazy var checkButton = UIButton()
	private lazy var tableView = UITableView()
	private lazy var footerView = UIView()
	private lazy var addButton = UIButton()
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	func bind(reactor: CategoryEditUpperReactor) {
		bindState(reactor)
		bindAction(reactor)
	}
}
//MARK: - Bind
extension CategoryEditUpperViewController {
	// MARK: 데이터 변경 요청 및 버튼 클릭시 요청 로직(View -> Reactor)
	private func bindAction(_ reactor: CategoryEditUpperReactor) {
		checkButton.rx.tap
			.subscribe(onNext: {
				self.navigationController?.popViewController(animated: true)
			}).disposed(by: disposeBag)
		
		// 카테고리 유형 추가
		addButton.rx.tap
			.withUnretained(self)
			.map { .didTapAddButton }
			.bind(to: reactor.action)
			.disposed(by: disposeBag)
		
		// 셀이 이동되었을때
		tableView.rx.itemMoved
			.bind(onNext: { [self] source, destination in
				let sourceCell = tableView.cellForRow(at: source) as! CategoryEditTableViewCell
				let destinationCell = tableView.cellForRow(at: destination) as! CategoryEditTableViewCell

				// 데이터 설정 - separator
				sourceCell.setData(last: destination.row == reactor.currentState.sections.map { $0.model.header }.count - 3)
			}).disposed(by: disposeBag)
	}
	
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: CategoryEditUpperReactor) {
		reactor.state
			.map { $0.sections.map { $0.model.header }.filter { $0.id != "header" && $0.id != "footer"} }
			.distinctUntilChanged() // 중복값 무시
			.bind(to: tableView.rx.items) { tv, row, data in
				let index = IndexPath(row: row, section: 0)
				let cell = tv.dequeueReusableCell(withIdentifier: CategoryEditTableViewCell.className, for: index) as! CategoryEditTableViewCell

				// 데이터 설정
				cell.setData(last: row == reactor.currentState.sections.map { $0.model.header }.count - 3)
				cell.reactor = CategoryEditTableViewCellReactor(provider: reactor.provider, categoryHeader: data)

				let backgroundView = UIView()
				backgroundView.backgroundColor = .clear
				cell.selectedBackgroundView = backgroundView
				
				return cell
			}.disposed(by: disposeBag)
		
		// 카테고리 편집
		reactor.state
			.compactMap { $0.nextEditScreen }
			.bind(onNext: willPresentEditViewController)
			.disposed(by: disposeBag)
		
		// 카테고리 유형 추가
		reactor.state
			.compactMap { $0.nextAddScreen }
			.distinctUntilChanged() // 중복값 무시
			.bind(onNext: willPresentAddViewController)
			.disposed(by: disposeBag)
	}
}
//MARK: - Action
extension CategoryEditUpperViewController {
	private func willPresentEditViewController(categoryHeader: CategoryHeader) {
		guard let reactor = self.reactor else { return }
		
		let vc = CategoryEditUpperBottomSheetViewController(title: "카테고리 유형 수정하기", categoryHeader: categoryHeader, height: 174)
		vc.reactor = CategoryEditUpperBottomSheetReactor(provider: reactor.provider)

		self.present(vc, animated: true, completion: nil)
	}
	
	private func willPresentAddViewController(isAdd: Bool) {
		guard let reactor = self.reactor else { return }
		
		let vc = CategoryAddUpperBottomSheetViewController(title: "카테고리 유형 추가하기", addId: reactor.currentState.addId - 1, height: 174)
		vc.reactor = CategoryEditUpperBottomSheetReactor(provider: reactor.provider)

		self.present(vc, animated: true, completion: nil)
	}
}
//MARK: - Attribute & Hierarchy & Layouts
extension CategoryEditUpperViewController {
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()
		
		navigationItem.title = "카테고리 유형 편집"
		navigationItem.rightBarButtonItem = UIBarButtonItem(customView: checkButton)
		view.backgroundColor = R.Color.gray900

		// Navigation Bar Right Button
		checkButton = checkButton.then {
			$0.setTitle("확인", for: .normal)
			$0.setTitleColor(R.Color.white.withAlphaComponent(0.7), for: .highlighted)
			$0.titleLabel?.font = R.Font.body1
		}
		
		tableView = tableView.then {
			$0.dragDelegate = self
			$0.dropDelegate = self
			$0.register(CategoryEditTableViewCell.self)
			$0.backgroundColor = R.Color.gray900
			$0.tableFooterView = footerView
			$0.showsVerticalScrollIndicator = false
			$0.separatorStyle = .none
			$0.rowHeight = 56
		}
		
		footerView = footerView.then {
			$0.frame = .init(origin: .zero, size: .init(width: tableView.frame.width, height: 44))
		}
		
		addButton = addButton.then {
			$0.setTitle("+ 카테고리 추가하기", for: .normal)
			$0.setTitleColor(R.Color.gray500, for: .normal)
			$0.setTitleColor(R.Color.gray500.withAlphaComponent(0.7), for: .highlighted)
			$0.setBackgroundColor(R.Color.gray800, for: .highlighted)
			$0.titleLabel?.font = R.Font.body1
			$0.contentHorizontalAlignment = .center
		}
	}
	
	override func setHierarchy() {
		super.setHierarchy()
		
		footerView.addSubview(addButton)
		view.addSubviews(tableView)
	}
	
	override func setLayout() {
		super.setLayout()
		
		tableView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
		
		addButton.snp.makeConstraints {
			$0.centerY.centerX.equalToSuperview()
			$0.horizontalEdges.equalToSuperview().inset(24)
			$0.height.equalTo(44)
		}
	}
}
// MARK: - UITableView Drag Delegate
extension CategoryEditUpperViewController: UITableViewDragDelegate {
	func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
		return [UIDragItem(itemProvider: NSItemProvider())]
	}
}
// MARK: - UITableView Drop Delegate
extension CategoryEditUpperViewController: UITableViewDropDelegate {
	func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
		return true
	}
	
	// drag가 활성화 되어 있는경우에만 drop이 동작하도록 구현
	// drag없이 drop이 동작할 수 없도록 하는 메소드
	func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
		guard tableView.hasActiveDrag else {
			return UITableViewDropProposal(operation: .forbidden)
		}
		
		return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
	}
	
	func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
		let destinationIndexPath: IndexPath
		
		if let indexPath = coordinator.destinationIndexPath {
			destinationIndexPath = indexPath
		} else {
			let section = tableView.numberOfSections - 1
			let row = tableView.numberOfRows(inSection: section)
			destinationIndexPath = IndexPath(row: row, section: section)
		}
		guard coordinator.proposal.operation == .move else { return }
		move(coordinator: coordinator, destinationIndexPath: destinationIndexPath, tableView: tableView)
	}
	
	private func move(coordinator: UITableViewDropCoordinator, destinationIndexPath: IndexPath, tableView: UITableView) {
		guard
			let sourceItem = coordinator.items.first,
			let sourceIndexPath = sourceItem.sourceIndexPath
		else { return }

		tableView.performBatchUpdates { [weak self] in
			self?.move(sourceIndexPath: sourceIndexPath, destinationIndexPath: destinationIndexPath)
		} completion: { finish in
			print(sourceItem.dragItem, destinationIndexPath)
			coordinator.drop(sourceItem.dragItem, toRowAt: destinationIndexPath)
		}
	}
	
	private func move(sourceIndexPath: IndexPath, destinationIndexPath: IndexPath) {
		// UI에 반영
		tableView.deleteRows(at: [sourceIndexPath], with: .automatic)
		tableView.insertRows(at: [destinationIndexPath], with: .automatic)
	}
}
