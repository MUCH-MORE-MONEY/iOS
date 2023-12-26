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
        case loadData(dateYM: String, rowNum: Int, valueScoreDvcd: String, id: String)
        case didTapPreviousButton
        case didTapNextButton
    }
    
    enum Mutation {
        case pushEditVC(Bool)
        case fetchSelectedActivity(SelectDetailResDto)
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
        var id: String
        // detail이랑 edit이랑 response 타입이 달라서 한번 더 fetch를 해줘야함
        var editActivity: SelectDetailResDto?
        
    }
    
    let initialState: State
    
    init(dateYM: String, rowNum: Int, totalItem: Int, valueScoreDvcd: String, id: String) {
        self.initialState = State(dateYM: dateYM, rowNum: rowNum, totalItem: totalItem, valueScoreDvcd: valueScoreDvcd, id: id)
        action.onNext(.loadData(dateYM: dateYM, rowNum: rowNum, valueScoreDvcd: valueScoreDvcd, id: id))
    }
}

//MARK: - Mutate, Transform, Reduce
extension DetailReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        let dateYM = self.currentState.dateYM
        let rowNum = self.currentState.rowNum
        let valueScoreDvcd = self.currentState.valueScoreDvcd
        
        switch action {
        case .didTapEditButton:
            return .concat([
                .just(.pushEditVC(true)),
                .just(.pushEditVC(false))
            ])
            
        case .loadData(let dateYM, let rowNum, let valueScoreDvcd, let id):
            return .concat([
                .just(.setLoading(true)),
                self.getStatisticsList(dateYM, rowNum, valueScoreDvcd, true),
                self.getSelectedActivity(by: id),
                .just(.setLoading(false))
            ])
            
        case .didTapNextButton:
            return .concat([
                .just(.updateIndex(1)),
                .just(.setLoading(true)),
                self.getStatisticsList(dateYM, rowNum + 1, valueScoreDvcd),
                .just(.setLoading(false))
            ])
            
        case .didTapPreviousButton:
            return .concat([
                .just(.updateIndex(-1)),
                .just(.setLoading(true)),
                self.getStatisticsList(dateYM, rowNum - 1, valueScoreDvcd),
                .just(.setLoading(false))
            ])
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
            
        case let .fetchSelectedActivity(activity):
            newState.editActivity = activity
        }
        
        return newState
    }
}

// MARK: - Action
extension DetailReactor {
    // 경제활동 만족도에 따른 List 불러오기 (사실 pagenation을 위한 api이지만 하나씩만 호출해서 사용함)
    func getStatisticsList(_ dateYM: String,_ rowNum: Int, _ type: String, _ reset: Bool = false) -> Observable<Mutation> {
        return MMMAPIService().getStatisticsList(dateYM: dateYM, valueScoreDvcd: type, limit: 1, offset: rowNum - 1)
            .map { (response, error) -> Mutation in
                return .fetchActivity(response.selectListMonthlyByValueScoreOutputDto)
            }
            .catchAndReturn(.setError)
    }
    // 경제활동 편집 기능도 수행하기 위해 selectedActivity 타입이 필요
    func getSelectedActivity(by id: String) -> Observable<Mutation> {
        return MMMAPIService().getSelectedActivity(id)
            .map { (response, error) -> Mutation in
                return .fetchSelectedActivity(response)
            }
            .catchAndReturn(.setError)
    }
}
