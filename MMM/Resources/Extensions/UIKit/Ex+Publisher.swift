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
    
    // Optional 값을 언랩하고, nil이 아닌 값들만 메인 스레드에서 받기 위한 메소드
    func compactMapOnMainThread<T>(_ transform: @escaping (Output) -> T?) -> Publishers.ReceiveOn<Publishers.CompactMap<Self, T>, DispatchQueue> {
        return self
            .compactMap(transform)
            .receive(on: DispatchQueue.main)
    }

    // Optional을 제거하고, nil이 아닌 값들만 메인 스레드에서 받는 sink 메소드
    func sinkCompactMapOnMainThread<T>(receiveCompletion: @escaping ((Subscribers.Completion<Self.Failure>) -> Void), receiveValue: @escaping ((T) -> Void)) -> AnyCancellable where Output == T? {
        
        return self
            .compactMap { $0 } // Optional 언랩
            .receive(on: DispatchQueue.main) // 메인 스레드로 이동
            .sink(receiveCompletion: receiveCompletion, receiveValue: receiveValue)
    }
    
    // Optional을 제거하고, nil이 아닌 값들만 메인 스레드에서 받는 sink 메소드, Failure가 Never인 경우
    func sinkCompactMapOnMainThread<T>(receiveValue: @escaping ((T) -> Void)) -> AnyCancellable where Output == T?, Self.Failure == Never {
        
        return self
            .compactMap { $0 } // Optional 언랩
            .receive(on: DispatchQueue.main) // 메인 스레드로 이동
            .sink(receiveValue: receiveValue)
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
    
    var textReturnPublisher: AnyPublisher<Void, Never> {
        controlPublisher(for: .editingDidEndOnExit)
            .compactMap{ $0 as? UITextField }
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
