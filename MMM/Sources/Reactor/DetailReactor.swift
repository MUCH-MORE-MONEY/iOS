//
//  DetailReactor.swift
//  MMM
//
//  Created by yuraMacBookPro on 12/21/23.
//

import Foundation
import ReactorKit

final class DetailReactor: Reactor {
    enum Action {
        case didTapEditButton
        case loadData(dateYM: String, rowNum: Int, valueScoreDvcd: String)
        case didTapPreviousButton
        case didTapNextButton
    }
    
    enum Mutation {
        case pushEditVC(Bool)
        case fetchActivity([EconomicActivity])
        case setLoading(Bool)
        case setError
        case updateIndex(Int)
    }
    
    struct State {
        var isPushEditVC = false
        var list: [EconomicActivity] = []
        var isLoading = true
        var index = 0
        var dateYM: String
        var rowNum: Int
        var totalItem: Int
        var valueScoreDvcd: String
    }
    
    let initialState: State
    
    init(dateYM: String, rowNum: Int, totalItem: Int, valueScoreDvcd: String) {
        self.initialState = State(dateYM: dateYM, rowNum: rowNum, totalItem: totalItem, valueScoreDvcd: valueScoreDvcd)
        action.onNext(.loadData(dateYM: dateYM, rowNum: rowNum, valueScoreDvcd: valueScoreDvcd))
    }
}

//MARK: - Mutate, Transform, Reduce
extension DetailReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .didTapEditButton:
            return .concat([
                .just(.pushEditVC(true)),
                .just(.pushEditVC(false))
            ])
            
        case .loadData(let dateYM, let rowNum, let valueScoreDvcd):
            return .concat([
                .just(.setLoading(true)),
                self.getStatisticsList(dateYM, rowNum, valueScoreDvcd, true),
                .just(.setLoading(false))
            ])
            
        case .didTapNextButton:
            return .just(.updateIndex(1))
            
        case .didTapPreviousButton:
            return .just(.updateIndex(-1))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .pushEditVC(isPush):
            newState.isPushEditVC = isPush
            
        case let .fetchActivity(list):
            newState.list = list

        case let .setLoading(isLoading):
            newState.isLoading = isLoading
            
        case .setError:
            newState.isLoading = false
        
        case let .updateIndex(index):
            newState.rowNum += index
        }
        
        return newState
    }
}

// MARK: - Action
extension DetailReactor {
    // 경제활동 만족도에 따른 List 불러오기
    func getStatisticsList(_ dateYM: String,_ rowNum: Int, _ type: String, _ reset: Bool = false) -> Observable<Mutation> {
        return MMMAPIService().getStatisticsList(dateYM: dateYM, valueScoreDvcd: type, limit: 1, offset: rowNum)
            .map { (response, error) -> Mutation in
                return .fetchActivity(response.selectListMonthlyByValueScoreOutputDto)
            }
            .catchAndReturn(.setError)
    }
}
