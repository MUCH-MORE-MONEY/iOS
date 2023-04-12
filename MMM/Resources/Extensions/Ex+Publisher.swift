//
//  Ex+Publisher.swift
//  MMM
//
//  Created by geonhyeong on 2023/04/11.
//

import Foundation
import Combine

public extension Publisher {
	
	func sinkOnMainThread(receiveCompletion: @escaping ((Subscribers.Completion<Self.Failure>) -> Void), receiveValue: @escaping ((Self.Output) -> Void)) -> AnyCancellable {
		
		return receive(on: DispatchQueue.main)
			.sink(receiveCompletion: receiveCompletion, receiveValue: receiveValue)
	}
	
	func sinkOnMainThread(receiveValue: @escaping ((Self.Output) -> Void)) -> AnyCancellable where Self.Failure == Never {
		
		return receive(on: DispatchQueue.main)
			.sink(receiveValue: receiveValue)
	}
}
