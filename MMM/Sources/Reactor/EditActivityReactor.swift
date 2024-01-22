//
//  EditActivityReactor.swift
//  MMM
//
//  Created by yuraMacBookPro on 1/9/24.
//

import Foundation
import ReactorKit

final class EditActivityReactor: Reactor {
    enum Action {
        case didTapEditButton
        case loadData
        case titleTextFieldChanged(String)
        case didTapCategoryView
        case didTapStarStackView
    }
    
    enum Mutation {
        case setData(SelectDetailResDto)
        case setLoading(Bool)
        case presentCategoryView(Bool)
        case presentStarPickerSheetViewController(Bool)
    }
    
    struct State {
        @Pulse var isLoading = true
        @Pulse var activity: SelectDetailResDto?
        @Pulse var isShowCategory = false
        @Pulse var isShowStarPicker = false
    }
    
    var initialState: State
    
    init(activity: SelectDetailResDto) {
        self.initialState = State(activity: activity)
    }
}

// MARK: - Mutate, Transform, Reduce
extension EditActivityReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadData:
            guard let activity = self.currentState.activity else { return .empty() }
            return .just(.setData(activity))
            
        case .didTapEditButton:
            return .concat([
                .just(.setLoading(true)),
                .just(.setLoading(false))
            ])
            
        case .titleTextFieldChanged(let title):
            guard var activity = self.currentState.activity else { return .empty() }
            activity.title = title
            return .just(.setData(activity))
            
        case .didTapCategoryView:
            return .concat([
                .just(.presentCategoryView(true)),
                .just(.presentCategoryView(false))
            ])
            
        case .didTapStarStackView:
            return .concat([
                .just(.presentStarPickerSheetViewController(true)),
                .just(.presentStarPickerSheetViewController(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .setData(activity):
            newState.activity = activity
            
        case let .setLoading(isLoading):
            newState.isLoading = isLoading
            
        case let .presentCategoryView(isShowCategory):
            newState.isShowCategory = isShowCategory
            
        case let .presentStarPickerSheetViewController(isShowStarPicker):
            newState.isShowStarPicker = isShowStarPicker
        }
        
        return newState
    }
}

// MARK: - Action
extension EditActivityReactor {
    
}
