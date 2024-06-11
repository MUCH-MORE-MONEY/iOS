//
//  StatisticsProvider.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/19.
//

import RxSwift
import Foundation

enum StatisticsEvent {
	case loadData
	case updateDate(Date)
	case changeBudge
	case updateSatisfaction(Satisfaction)
}

protocol StatisticsServiceProtocol {
	var event: PublishSubject<StatisticsEvent> { get }
	
	func loadData()
	func updateDate(to date: Date) -> Observable<Date>
	func changeBudge() -> Observable<Bool>
	func updateSatisfaction(to satisfaction: Satisfaction) -> Observable<Satisfaction>
}

final class StatisticsProvider: StatisticsServiceProtocol {
	let event = PublishSubject<StatisticsEvent>()
	
	func loadData() {
		event.onNext(.loadData)
	}
	
	func updateDate(to date: Date) -> Observable<Date> {
		event.onNext(.updateDate(date))
		
		return .just(date)
	}
	
	func changeBudge() -> Observable<Bool> {
		event.onNext(.changeBudge)
		
		return .just(true)
	}
	
	func updateSatisfaction(to satisfaction: Satisfaction) -> Observable<Satisfaction> {
		event.onNext(.updateSatisfaction(satisfaction))
		
		return .just(satisfaction)
	}
}
