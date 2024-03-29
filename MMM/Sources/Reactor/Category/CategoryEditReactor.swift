//
//  CategoryEditReactor.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/24.
//

import ReactorKit
import Foundation

final class CategoryEditReactor: Reactor {
	// 사용자의 액션
	enum Action {
		case loadData(String)
		case didTabSaveButton
		case didTabBackButton
		case didTapAddButton(CategoryHeader) // 카테고리 추가
		case didTapUpperEditButton // 카테고리 유형 편집
		case dragAndDrop(IndexPath, IndexPath)
		case dragAndDropByEmpty
		case dragBegin([IndexPath])
		case dragEnd([IndexPath])
		case endAddToast
		case endDeleteToast
	}
	
	// 처리 단위
	enum Mutation {
		case setHeaders([CategoryHeader])
		case setSections([CategoryEditSectionModel])
		case addItem(CategoryEdit)
		case deleteItem(CategoryEdit)
		case dragAndDrop(IndexPath, IndexPath)
		case dragAndDropByEmpty
		case addDrag([IndexPath])
		case removeEmpty([IndexPath])
		case setRemovedUpperCategory([String:String])
		case setPresentAlert(Bool)
		case setNextEditScreen(CategoryEdit?)
		case setNextAddScreen(CategoryHeader?)
		case setNextUpperEditScreen(Bool)
		case setAddFlag(Bool)
		case setDeleteFlag(Bool)
		case setLoading(Bool)
		case setError
		case dismiss
	}
	
	// 현재 상태를 기록
	struct State {
		var addId: Int = 0
		var type: String
		var headers: [CategoryHeader] = []
		var preSections: [CategoryEditUpperPut]?
		var sectionInfo: (section: [CategoryEditSectionModel], refresh: Bool) = ([], false) // Section List와 refresh 해야하는 타이밍
		var removedUpperCategory: [String:String] = [:] // id:title
		var removedCategory: [String:String] = [:] // id:title
		var nextEditScreen: CategoryEdit?
		var nextAddScreen: CategoryHeader?
		var nextUpperEditScreen: Bool = false
		var isEdit = false
		var isAdd = false
		var isDelete = false
		var isLoading = false // 로딩
		var dismiss = false
		var error = false
	}
	
	// MARK: Properties
	let initialState: State
	let provider: ServiceProviderProtocol

	init(provider: ServiceProviderProtocol, type: String) {
		self.initialState = State(type: type)
		self.provider = provider
		
		// 뷰가 최초 로드 될 경우
		action.onNext(.loadData(type))
	}
}
//MARK: - Mutate, Reduce
extension CategoryEditReactor {
	/// Action이 들어온 경우, 어떤 처리를 할건지 분기
	func mutate(action: Action) -> Observable<Mutation> {
		switch action {
		case let .loadData(type):
			return .concat([
				.just(.setLoading(true)),
				loadHeaderData(CategoryEditReqDto(economicActivityDvcd: type)),
				loadCategoryData(CategoryEditReqDto(economicActivityDvcd: type)),
				.just(.setLoading(false))
			])
		case .didTabSaveButton:
			return .concat([
				.just(.setLoading(true)),
				compareData(),
				provider.categoryProvider.refresh(isRefresh: true).map { _ in .setLoading(false)}
			])
		case .didTabBackButton:
			// 수정이 되었는지 판별
			return .concat([
				.just(.setPresentAlert(true)),
				.just(.setPresentAlert(false))
			])
		case let .didTapAddButton(categoryHeader):
			return .concat([
				.just(.setNextAddScreen(categoryHeader)),
				.just(.setNextAddScreen(nil))
			])
		case .didTapUpperEditButton:
			return .concat([
				.just(.setNextUpperEditScreen(true)),
				.just(.setNextUpperEditScreen(false))
			])
		case let .dragAndDrop(startIndex, destinationIndexPath):
			return .just(.dragAndDrop(startIndex, destinationIndexPath))
		case .dragAndDropByEmpty:
			return .just(.dragAndDropByEmpty)
		case let .dragBegin(indexPathList):
			return .just(.addDrag(indexPathList))
		case let .dragEnd(indexPathList):
			return .just(.removeEmpty(indexPathList))
		case .endAddToast:
			return .just(.setAddFlag(false))
		case .endDeleteToast:
			return .just(.setDeleteFlag(false))
		}
	}
	
	/// 각각의 stream을 변형
	func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
		let event = provider.categoryProvider.event.flatMap { event -> Observable<Mutation> in
			switch event {
			case let .presentTitleEdit(categoryEdit):
				return .concat([
					.just(.setNextEditScreen(categoryEdit)),
					.just(.setNextEditScreen(nil))
				])
			case let .addCategory(categoryEdit):
				return .just(.addItem(categoryEdit))
			case let .deleteTitleEdit(categoryEdit):
				return .just(.deleteItem(categoryEdit))
			case let .saveSections(sections): // 카테고리 유형 편집에 대한 저장
				return .just(.setSections(sections))
			case let .deleteList(removedUpperList):
				return .just(.setRemovedUpperCategory(removedUpperList))
			default:
				return .empty()
			}
		}
		
		return Observable.merge(mutation, event)
	}
	
	/// 이전 상태와 처리 단위(Mutation)를 받아서 다음 상태(State)를 반환하는 함수
	func reduce(state: State, mutation: Mutation) -> State {
		var newState = state
		
		switch mutation {
		case let .setHeaders(headers):
			newState.addId = -headers.count
			newState.headers = headers
		case let .setSections(sections):
			newState.sectionInfo.section = sections
			newState.sectionInfo.refresh = true

			// 편집전 sections 정보 저장
			if newState.preSections == nil {
				newState.preSections = self.transformData(input: sections)
			}
		case let .addItem(categoryEdit):
			if let section = newState.sectionInfo.section.enumerated().filter({ $0.element.model.header.id == categoryEdit.upperId }).first {
				let sectionId = section.offset
				
				// 데이터를 넣기 전에 Empty Cell이 있는지 확인후 제거
				if let first = newState.sectionInfo.section[sectionId].items.first {
					switch first {
					case .empty:	newState.sectionInfo.section[sectionId].items.removeAll()
					default: 		break
					}
				}
				
				var newItem = categoryEdit
				newItem.orderNum = newState.sectionInfo.section[sectionId].items.count + 1
				let categoryEditItem: CategoryEditItem = .base(.init(provider: provider, categoryEdit: newItem))
				
				newState.sectionInfo.section[sectionId].items.append(categoryEditItem) // 해당 Sections을 찾아서 append
				newState.addId -= 1 // 1씩 감소 시키면서 고유한 값 유지
				newState.sectionInfo.refresh = true
				newState.isAdd = true // Toast Message
			}
		case let .deleteItem(categoryEdit):		
			if let section = newState.sectionInfo.section.enumerated().filter({ !$0.element.items.filter({ $0.identity as! String == categoryEdit.id }).isEmpty}).first {
				let sectionId = section.offset
				
				if let removeIndex = newState.sectionInfo.section[sectionId].items.firstIndex(where: {$0.identity as! String == categoryEdit.id}) {
					
					// 삭제된 카테고리 저장
					let item = newState.sectionInfo.section[sectionId].items[removeIndex]
					let (id, title) = (item.identity as! String, item.title)
					newState.removedCategory[id] = title

					newState.sectionInfo.section[sectionId].items.remove(at: removeIndex)
					
					// 카테고리가 비어있을 경우, Empty Cell 추가
					if newState.sectionInfo.section[sectionId].items.isEmpty {
						newState.sectionInfo.section[sectionId].items.append(.empty)
					}
					
					newState.sectionInfo.refresh = true
					newState.isDelete = true // Toast Message
				}
			}
		case let .dragAndDrop(sourceIndexPath, destinationIndexPath):
			var isRefresh: Bool = false

			let sourceItem = newState.sectionInfo.section[sourceIndexPath.section].items[sourceIndexPath.row]
			newState.sectionInfo.section[sourceIndexPath.section].items.remove(at: sourceIndexPath.row)
			newState.sectionInfo.section[destinationIndexPath.section].items.insert(sourceItem, at: destinationIndexPath.row)

			// '출발지'의 카테고리가 비어있을 경우, Empty Cell 추가
			if newState.sectionInfo.section[sourceIndexPath.section].items.isEmpty {
				newState.sectionInfo.section[sourceIndexPath.section].items.append(.empty)
				isRefresh = true
			}
			
			// '목적지'의 카테고리가 비어있을 경우, Empty Cell 삭제
			if let first = newState.sectionInfo.section[destinationIndexPath.section].items.first {
				switch first {
				case .empty: 	
					newState.sectionInfo.section[destinationIndexPath.section].items.removeFirst()
					isRefresh = true
				default: 		break
				}
			}
			
			// '목적지'의 카테고리가 비어있을 경우, Empty Cell 삭제
			if let last = newState.sectionInfo.section[destinationIndexPath.section].items.last {
				switch last {
				case .empty:
					newState.sectionInfo.section[destinationIndexPath.section].items.removeLast()
					isRefresh = true
				default: 		break
				}
			}

			newState.sectionInfo.refresh = isRefresh
		case .dragAndDropByEmpty:
			if newState.sectionInfo.section[0].items.count == 1 {
				let headerItem: CategoryEditItem = .header(.init(provider: provider, categoryEdit: CategoryEdit.getDummy()))
				newState.sectionInfo.section[0].items.append(headerItem)
			} else {
				newState.sectionInfo.section[0].items.removeLast()
			}
			newState.sectionInfo.refresh = true
		case let .addDrag(indexPathList):
			for indexPath in indexPathList {
				newState.sectionInfo.section[indexPath.section].items.append(.drag)
				newState.sectionInfo.refresh = true
			}
		case let .removeEmpty(indexPathList):
			for indexPath in indexPathList {
				newState.sectionInfo.section[indexPath.section].items.remove(at: indexPath.row)
			}
		case let .setRemovedUpperCategory(removedUpperCategory):
			for (id, title) in removedUpperCategory {
				newState.removedUpperCategory[id] = title
			}
		case let .setNextEditScreen(categoryEdit):
			newState.nextEditScreen = categoryEdit
		case let .setNextAddScreen(categoryHeader):
			newState.nextAddScreen = categoryHeader
		case let .setNextUpperEditScreen(isNext):
			newState.nextUpperEditScreen = isNext
		case let .setPresentAlert(isAlert): // 수정되었는지 판별
			if isAlert {
				if let pre = newState.preSections {
					let isEdit = pre == self.transformData(input: newState.sectionInfo.section)
					newState.isEdit = !isEdit

					if isEdit { newState.dismiss = true }
					
				} else { // 에러가 생겨 데이터를 받아오지 못하면 Dismiss 작동
					newState.dismiss = true
				}
			} else {
				newState.isEdit = false
			}
		case let .setAddFlag(flag):
			newState.isAdd = flag
		case let .setDeleteFlag(flag):
			newState.isDelete = flag
		case let .setLoading(isLoading):
			newState.isLoading = isLoading
		case .setError:
			newState.isLoading = false
		case .dismiss:
			newState.dismiss = true
		}
		
		return newState
	}
}
//MARK: - Action
extension CategoryEditReactor {
	// 데이터 Header 가져오기
	private func loadHeaderData(_ request: CategoryEditReqDto) -> Observable<Mutation> {
		return MMMAPIService().getCategoryEditHeader(request)
			.map { (response, error) -> Mutation in
				return .setHeaders(response.data.selectListUpperOutputDto)
			}
	}
	
	// 데이터 가져오기
	private func loadCategoryData(_ request: CategoryEditReqDto) -> Observable<Mutation> {
		return MMMAPIService().getCategoryEdit(request)
			.map { (response, error) -> Mutation in
				return .setSections(self.makeSections(respose: response, type: request.economicActivityDvcd))
			}
			.catchAndReturn(.setError)
	}
	
	// Section에 따른 Data 주입
	private func makeSections(respose: CategoryEditResDto, type: String) -> [CategoryEditSectionModel] {
		guard let respose = respose.data else { return [] }
		let data = respose.selectListOutputDto
		
		var sections: [CategoryEditSectionModel] = []

		// Global Header
		let headerItem: CategoryEditItem = .header(.init(provider: provider, categoryEdit: CategoryEdit.getDummy()))
		let headerModel: CategoryEditSectionModel = .init(model: .header(headerItem), items: [headerItem])
		sections.append(headerModel)
		
		for header in currentState.headers {
			var categoryitems: [CategoryEditItem] = data.filter { $0.upperId == header.id }.map { categoryEdit -> CategoryEditItem in
				return .base(.init(provider: provider, categoryEdit: categoryEdit))
			}
			
			// 빈 List는 empty cell 주입
			if categoryitems.isEmpty { categoryitems.append(.empty) }
			
			let model: CategoryEditSectionModel = .init(model: .base(header, categoryitems), items: categoryitems)
			sections.append(model)
		}
		
		// Global Footer
		let footerItem: CategoryEditItem = .footer(.init(provider: provider, categoryEdit: CategoryEdit.getDummy()))
		let footerModel: CategoryEditSectionModel = .init(model: .footer(footerItem), items: [footerItem])
		sections.append(footerModel)
		
		return sections
	}
}
// MARK: - 저장
extension CategoryEditReactor {
	// 비교를 위한 Model 전환
	private func transformData(input: [CategoryEditSectionModel]) -> [CategoryEditUpperPut] {
		guard 1 < input.count else { return [] }
		
		return input[1..<input.count - 1].map { section -> CategoryEditUpperPut in
			let id = section.model.header.id
			let title = section.model.header.title
			let list: [CategoryEditPut] = section.items.map { item -> CategoryEditPut in
				return .init(id: item.identity as! String, title: item.title, useYn: "")
			}
			return .init(id: id, title: title, useYn: "", list: list)
		}
	}
	
	// 변경된 데이터 확인하기
	private func compareData() -> Observable<Mutation> {
		var request: PutCategoryEditReqDto = .init(economicActivityDvcd: currentState.type, data: [])
		let data = currentState.sectionInfo.section
		let removedUpperCategory = currentState.removedUpperCategory

		for i in stride(from: 1, to: data.count - 1, by: 1) {
			let section = data[i]
			let header = data[i].model.header
			var upper: CategoryEditUpperPut = .init(id: header.id, title: header.title, useYn: "Y", list: [])

			// 추가된 상위 카테고리에 대한 처리
			if let id = Int(header.id) {
				if id < 0 {
					upper.id = ""
				}
			}
						
			for j in stride(from: 0, to: section.items.count, by: 1) {
				let id = section.items[j].identity as! String
				
				// 빈 Cell에 대한 예외처리
				if id == "" { continue }
				
				let title = section.items[j].title
				var lowwer: CategoryEditPut = .init(id: id, title: title, useYn: "Y")
				
				// 추가된 카테고리에 대한 처리
				if let id = Int(id) {
					if id < 0 {
						lowwer.id = ""
					}
				}
				
				upper.list.append(lowwer)
			}
			request.data.append(upper)
		}
		
		// 마지막 배열에 넣기
		if let _ = request.data.last {
			// 삭제된 카테고리
			for (id, title) in currentState.removedCategory {
				if let id = Int(id), id < 0 {
					continue
				}
				let lowwer: CategoryEditPut = .init(id: id, title: title, useYn: "N")
				request.data[request.data.count - 1].list.append(lowwer)
			}
		}
		
		// 배열에 삭제된 상위 카테고리 넣기
		for (id, title) in removedUpperCategory {
			if let id = Int(id), id < 0 {
				continue
			}
			
			let upper: CategoryEditUpperPut = .init(id: id, title: title, useYn: "N", list: [])
			request.data.append(upper)
		}
		
		return MMMAPIService().putCategoryEdit(request)
			.map { (response, error) -> Mutation in
				return .dismiss
			}
	}
}
