//
//  DetailProvider.swift
//  MMM
//
//  Created by yuraMacBookPro on 12/21/23.
//

import RxSwift

enum DetailEvent {
    case updatePageIndex(Int)
}

protocol DetailServiceProtocol {
    var event: PublishSubject<DetailEvent> { get }
    
    func updatePageIndex(_ index: Int) -> Observable<Int>
}

final class DetailProvider: DetailServiceProtocol {
    let event = PublishSubject<DetailEvent>()
    
    func updatePageIndex(_ index: Int) -> Observable<Int> {
        event.onNext(.updatePageIndex(index))
        
        return .just(index)
    }
}
