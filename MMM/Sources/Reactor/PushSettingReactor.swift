//
//  PushSettingReactor.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/08/24.
//

import Foundation
import ReactorKit
import Moya

final class PushSettingReactor: Reactor {
    enum Action {
        case didTapTimeSettingButton
        case didTapTextSettingButton
    }
    
    enum Mutation {
        case setPresentTimeDetail
        case setPresentTextDetail(PushResDto)
    }
    
    struct State {
        var isPresentTimeDetail = false
        var isPresentTextDetail = false
        var pushMessage = ""
    }
    
    let initialState: State
    
    init() { initialState = State() }
}

extension PushSettingReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
            
        case .didTapTimeSettingButton:
            return .just(.setPresentTimeDetail)
            
        case .didTapTextSettingButton:
            return push()
            
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        newState.isPresentTimeDetail = false
        newState.isPresentTextDetail = false
        
        switch mutation {
            
        case .setPresentTimeDetail:
            newState.isPresentTimeDetail = true
            
        case .setPresentTextDetail(let response):
            newState.isPresentTextDetail = true
            newState.pushMessage = response.message
            
        }
        
        return newState
    }
}

// MARK: - Actions
extension PushSettingReactor {
    
    private func push() -> Observable<Mutation> {
        let pushRequest = PushRequest(content: "12", pushAgreeDvcd: "12")
        
        return MyAPI
            .push(pushRequest)
            .request()
            .map {
                let jsonString = try $0.mapString().removedEscapeCharacters
                guard let value = jsonString.data(using: .utf8) else { return $0 }
                
                let newResponse = Response(
                    statusCode: $0.statusCode,
                    data: value,
                    request: $0.request,
                    response: $0.response)
                
                return newResponse
            }
            .map(PushResDto.self, using: MyAPI.jsonDecoder)
            .map { data -> Mutation in
                return .setPresentTextDetail(data)
            }
            .asObservable()
        
    }
}
