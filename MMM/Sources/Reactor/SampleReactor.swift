//
//  SampleReactor.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/08/12.
//

import Foundation
import ReactorKit

typealias ResultModel = (id: String, title: String)

final class MainViewReactor: Reactor {
    enum Action {
        case requestList(Int)
    }
    
    enum Mutation {
        case requestList([ResultModel])
        case setLoading(Bool)
    }
    // MARK: View 혹은 ViewController에서 바인딩할 데이터
    struct State {
        var list: [ResultModel] = []
        var isLoading: Bool = false
    }
    
    var initialState: State
    
    init() {
        initialState = State()
        // MARK: 초기 진입시 리스트 요청해야 할 경우에 사용되곤 함
        action.onNext(.requestList(0))
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .requestList(_):
            return .concat(.just(.setLoading(true)), .just(.requestList([])), .just(.setLoading(false)))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        return state
    }
}
