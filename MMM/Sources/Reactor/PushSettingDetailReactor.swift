//
//  PushSettingDetailReactor.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/09/07.
//

import Foundation
import ReactorKit
import RxSwift

final class PushSettingDetailReactor: Reactor {
    enum Action {
        case didTapDetailTimeSettingView
    }
    
    enum Mutation {
		case setDate(Date)
        case setPresentTime(Bool)
    }
    
    struct State {
		var date = Date()
        var isPresentTime = false
    }
    
    let initialState: State
	let provider: StatisticsServiceProtocol

    init(provider: StatisticsServiceProtocol) {
		self.initialState = State()
		self.provider = provider
    }
}

extension PushSettingDetailReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .didTapDetailTimeSettingView:
            return Observable.concat([
                .just(.setPresentTime(true)),
                .just(.setPresentTime(false))
            ])
        }
    }
	
	/// 각각의 stream을 변형
	func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
		let tagEvent = provider.event.flatMap { event -> Observable<Mutation> in
			switch event {
			case .updateDate(let date):
				return .just(.setDate(date))
			}
		}
		
		return Observable.merge(mutation, tagEvent)
	}
	
    
	func reduce(state: State, mutation: Mutation) -> State {
		var newState = state
		
		switch mutation {
		case .setDate(let date):
			newState.date = date
		case .setPresentTime(let isPresent):
			newState.isPresentTime = isPresent
		}
        return newState
    }
}
