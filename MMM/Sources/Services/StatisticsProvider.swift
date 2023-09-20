//
//  StatisticsProvider.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/19.
//

import RxSwift

enum StatisticsEvent {
	case updateDate(Date)
	case updateSatisfaction(Satisfaction)
}

protocol StatisticsServiceProtocol {
	var event: PublishSubject<StatisticsEvent> { get }
	
	func updateDate(to date: Date) -> Observable<Date>
	func updateSatisfaction(to satisfaction: Satisfaction) -> Observable<Satisfaction>
}

final class StatisticsProvider: StatisticsServiceProtocol {
	let event = PublishSubject<StatisticsEvent>()
	
	func updateDate(to date: Date) -> Observable<Date> {
		event.onNext(.updateDate(date))
		
		return .just(date)
	}
	
	func updateSatisfaction(to satisfaction: Satisfaction) -> Observable<Satisfaction> {
		event.onNext(.updateSatisfaction(satisfaction))
		
		return .just(satisfaction)
	}
}
