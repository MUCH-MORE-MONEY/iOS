//
//  CategoryProvider.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/27.
//

import RxSwift

enum CategoryEvent {
	case presentTitleEdit(CategoryEdit)
	case addCategory(CategoryEdit)
	case updateTitleEdit(CategoryEdit)
	case deleteTitleEdit(CategoryEdit)
	
	case presentUpperEdit(CategoryHeader)
	case addUpper(CategoryHeader)
	case updateUpperEdit(CategoryHeader)
	case deleteUpperEdit(CategoryHeader)
}

protocol CategoryServiceProtocol {
	var event: PublishSubject<CategoryEvent> { get }
	
	func presentTitleEdit(to categoryEdit: CategoryEdit) -> Observable<CategoryEdit>
	func addCategory(to categoryEdit: CategoryEdit) -> Observable<CategoryEdit>
	func updateTitleEdit(to categoryEdit: CategoryEdit) -> Observable<CategoryEdit>
	func deleteTitleEdit(to categoryEdit: CategoryEdit) -> Observable<CategoryEdit>

	func presentUpperEdit(to categoryHeader: CategoryHeader) -> Observable<CategoryHeader>
	func addUpper(to categoryHeader: CategoryHeader) -> Observable<CategoryHeader>
	func updateUpperEdit(to categoryHeader: CategoryHeader) -> Observable<CategoryHeader>
	func deleteUpperEdit(to categoryHeader: CategoryHeader) -> Observable<CategoryHeader>
}

final class CategoryProvider: CategoryServiceProtocol {
	let event = PublishSubject<CategoryEvent>()
	
	func presentTitleEdit(to categoryEdit: CategoryEdit) -> Observable<CategoryEdit> {
		event.onNext(.presentTitleEdit(categoryEdit))
		
		return .just(categoryEdit)
	}
	
	func addCategory(to categoryEdit: CategoryEdit) -> Observable<CategoryEdit> {
		event.onNext(.addCategory(categoryEdit))
		
		return .just(categoryEdit)
	}
	
	func updateTitleEdit(to categoryEdit: CategoryEdit) -> Observable<CategoryEdit> {
		event.onNext(.updateTitleEdit(categoryEdit))
		
		return .just(categoryEdit)
	}
	
	func deleteTitleEdit(to categoryEdit: CategoryEdit) -> Observable<CategoryEdit> {
		event.onNext(.deleteTitleEdit(categoryEdit))
		
		return .just(categoryEdit)
	}
	
	func presentUpperEdit(to categoryHeader: CategoryHeader) -> Observable<CategoryHeader> {
		event.onNext(.presentUpperEdit(categoryHeader))
		
		return .just(categoryHeader)
	}
	
	func addUpper(to categoryHeader: CategoryHeader) -> RxSwift.Observable<CategoryHeader> {
		event.onNext(.addUpper(categoryHeader))
		
		return .just(categoryHeader)
	}
	
	func updateUpperEdit(to categoryHeader: CategoryHeader) -> RxSwift.Observable<CategoryHeader> {
		event.onNext(.updateUpperEdit(categoryHeader))
		
		return .just(categoryHeader)
	}
	
	func deleteUpperEdit(to categoryHeader: CategoryHeader) -> RxSwift.Observable<CategoryHeader> {
		event.onNext(.deleteUpperEdit(categoryHeader))
		
		return .just(categoryHeader)
	}
}
