//
//  CategoryProvider.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/27.
//

import RxSwift

enum CategoryEvent {
	case presentTitleEdit(CategoryEdit)
}

protocol CategoryServiceProtocol {
	var event: PublishSubject<CategoryEvent> { get }
	
	func presentTitleEdit(to categoryEdit: CategoryEdit) -> Observable<CategoryEdit>
}

final class CategoryProvider: CategoryServiceProtocol {
	let event = PublishSubject<CategoryEvent>()
	
	func presentTitleEdit(to categoryEdit: CategoryEdit) -> Observable<CategoryEdit> {
		event.onNext(.presentTitleEdit(categoryEdit))
		
		return .just(categoryEdit)
	}
}
