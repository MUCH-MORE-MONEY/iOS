//
//  Ex+Publisher.swift
//  MMM
//
//  Created by geonhyeong on 2023/04/11.
//

import Combine
import UIKit

public extension Publisher {
	
	func sinkOnMainThread(receiveCompletion: @escaping ((Subscribers.Completion<Self.Failure>) -> Void), receiveValue: @escaping ((Self.Output) -> Void)) -> AnyCancellable {
		
		return receive(on: DispatchQueue.main)
			.sink(receiveCompletion: receiveCompletion, receiveValue: receiveValue)
	}
	
	func sinkOnMainThread(receiveValue: @escaping ((Self.Output) -> Void)) -> AnyCancellable where Self.Failure == Never {
		
		return receive(on: DispatchQueue.main)
			.sink(receiveValue: receiveValue)
	}
	
	func assignOnMainThread<Root>(to: ReferenceWritableKeyPath<Root, Self.Output>, on: Root) -> AnyCancellable where Self.Failure == Never {
		
		return receive(on: DispatchQueue.main)
			.assign(to: to, on: on)
	}
}

extension UIButton {
	var tapPublisher: AnyPublisher<Void, Never> {
		controlPublisher(for: .touchUpInside)
			.map { _ in }
			.eraseToAnyPublisher()
	}
	
	/// Tag 값으로 분류
	var tapPublisherByTag: AnyPublisher<Int, Never> {
		controlPublisher(for: .touchUpInside)
			.map { $0.tag }
			.eraseToAnyPublisher()
	}
}

extension UISwitch {
	var statePublisher: AnyPublisher<Bool, Never> {
		controlPublisher(for: .valueChanged)
			.map { $0 as! UISwitch }
			.map { $0.isOn }
			.eraseToAnyPublisher()
	}
}

extension UITextField {
	var textPublisher: AnyPublisher<String, Never> {
		controlPublisher(for: .editingChanged)
			.compactMap { $0 as? UITextField }
			.map { $0.text! }
			.eraseToAnyPublisher()
	}
    var endEditPublisher: AnyPublisher<String, Never> {
        controlPublisher(for: .editingDidEnd)
            .compactMap{ $0 as? UITextField }
            .map{ $0.text! }
            .eraseToAnyPublisher()
    }
}

extension UIPageControl {
    var tapPublisher: AnyPublisher<Void, Never> {
        controlPublisher(for: .valueChanged)
            .map{ _ in }
            .eraseToAnyPublisher()
    }
}
