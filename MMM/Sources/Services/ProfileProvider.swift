//
//  ProfileService.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/20.
//

import RxSwift

enum ProfileEvent {
	case updateDate(Date)
}

protocol ProfileServiceProtocol {
	var event: PublishSubject<ProfileEvent> { get }
	
	func updateDate(to date: Date) -> Observable<Date>
}

final class ProfileProvider: ProfileServiceProtocol {
	let event = PublishSubject<ProfileEvent>()
	
	func updateDate(to date: Date) -> Observable<Date> {
		event.onNext(.updateDate(date))
		
		return .just(date)
	}
}
