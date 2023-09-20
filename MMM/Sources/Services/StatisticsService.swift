//
//  StatisticsService.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/19.
//

import RxSwift

enum StatisticsEvent {
	case updateDate(Date)
}

protocol StatisticsServiceProtocol {
	var event: PublishSubject<StatisticsEvent> { get }
	
	func updateDate(to date: Date) -> Observable<Date>
}

final class StatisticsService: StatisticsServiceProtocol {
	let event = PublishSubject<StatisticsEvent>()
	
	func updateDate(to date: Date) -> Observable<Date> {
		event.onNext(.updateDate(date))
		
		return .just(date)
	}
}
