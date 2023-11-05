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
final class CategoryEditUpperViewController: BaseViewController, View {
	typealias Reactor = CategoryEditUpperReactor

	// MARK: - Constants
	private enum UI {}
	
	// MARK: - Properties
	
	// MARK: - UI Components
	private lazy var backButtonItem = UIBarButtonItem()
	private lazy var backButton = UIButton()
	private lazy var saveButton = UIButton()
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
		// 저장 버튼
		saveButton.rx.tap
			.withUnretained(self)
			.map { .didTabSaveButton }
			.bind(to: reactor.action)
			.disposed(by: disposeBag)
		
		// 뒤로가기 버튼
		backButton.rx.tap
			.withUnretained(self)
			.map { .didTabBackButton }
			.bind(to: reactor.action)
			.disposed(by: disposeBag)
		
		// 카테고리 유형 추가
		addButton.rx.tap
			.withUnretained(self)
			.map { .didTapAddButton }
			.bind(to: reactor.action)
			.disposed(by: disposeBag)
		
		// 셀이 이동되었을때
		tableView.rx.itemMoved
			.bind(onNext: { [self] source, destination in
				// DataSource 이동
				self.reactor?.action.onNext(.dragAndDrop(source, destination))
			}).disposed(by: disposeBag)
	}
	
	// MARK: 데이터 바인딩 처리 (Reactor -> View)
	private func bindState(_ reactor: CategoryEditUpperReactor) {
		// 타입 추론이 길어서 반으로 나누기
		let datasource = reactor.state
			.map { $0.sections.map { $0.model.header }.filter { $0.id != "header" } }
			.distinctUntilChanged { $0.count == $1.count } // 순서만 바뀌었을 때에는 변경안함
		
		datasource
			.bind(to: tableView.rx.items) { tv, row, data in
				let index = IndexPath(row: row, section: 0)
				let cell = tv.dequeueReusableCell(withIdentifier: CategoryEditTableViewCell.className, for: index) as! CategoryEditTableViewCell

				// 데이터 설정
				// Grobal Header가 존재해서 - 1
				cell.setData(last: row == reactor.currentState.sections.count - 2)
				cell.reactor = CategoryEditTableViewCellReactor(provider: reactor.provider, categoryHeader: data)

				// Click에 대한 색상
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
		
		// 카테고리 유형 추가
		reactor.state
			.compactMap { $0.dismiss }
			.filter { $0 }
			.distinctUntilChanged() // 중복값 무시
			.bind(onNext: { _ in
				if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
					sceneDelegate.window?.showToast(message: "카테고리 유형이 수정되었습니다")
				}
				
				self.navigationController?.popViewController(animated: true)
			})
			.disposed(by: disposeBag)
		
		// 수정 여부에 따른 Alert present
		reactor.state
			.map { $0.isEdit }
			.distinctUntilChanged() // 중복값 무시
			.filter { $0 } // true 일때만
			.bind(onNext: willPresentAlert)
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
//MARK: - 알림
extension CategoryEditUpperViewController: CustomAlertDelegate {
	// 편집 여부에 따른 Present
	private func willPresentAlert(isEdit: Bool) {
		showAlert(alertType: .canCancel, titleText: "카테고리 유형 편집 나가기", contentText: "화면을 나가면 변경사항은 저장되지 않습니다.\n 나가시겠습니까?", confirmButtonText: "나가기")
	}
	
	func didAlertCofirmButton() {
		self.navigationController?.popViewController(animated: true) // 나가기
	}
	
	func didAlertCacelButton() { }
}
//MARK: - Attribute & Hierarchy & Layouts
extension CategoryEditUpperViewController {
	// 초기 셋업할 코드들
	override func setAttribute() {
		super.setAttribute()
		
		navigationItem.title = "카테고리 유형 편집"
		navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
		view.backgroundColor = R.Color.gray900
		navigationItem.leftBarButtonItem = backButtonItem

		backButtonItem = backButtonItem.then {
			$0.customView = backButton
		}
		
		// Navigation Bar Left Button
		backButton = backButton.then {
			$0.setImage(R.Icon.arrowBack24, for: .normal)
		}

		// Navigation Bar Right Button
		saveButton = saveButton.then {
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
	
	func tableView(_ tableView: UITableView, dragSessionDidEnd session: UIDragSession) {
		guard let reactor = reactor else { return }
		
		// 마지막 아이템의 separator 제거
		// 2을 빼는 이유 : Global header가 있음
		let count = reactor.currentState.sections.count - 2
		
		for row in stride(from: 0, through: count, by: 1) {
			let index = IndexPath(row: row, section: 0)
			let cell = tableView.cellForRow(at: index) as! CategoryEditTableViewCell
			cell.setData(last: row == count)
		}
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
			coordinator.drop(sourceItem.dragItem, toRowAt: destinationIndexPath)
		}
	}
	
	private func move(sourceIndexPath: IndexPath, destinationIndexPath: IndexPath) {
		// UI에 반영
		tableView.deleteRows(at: [sourceIndexPath], with: .automatic)
		tableView.insertRows(at: [destinationIndexPath], with: .automatic)
	}
}
