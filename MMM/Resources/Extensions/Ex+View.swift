//
//  Ex+View.swift
//  MMM
//
//  Created by geonhyeong on 2023/03/27.
//  Copyright © 2023 Lab.M. All rights reserved.
//

import UIKit
import Combine

extension UIView {
    
    func gesturePublisher(_ gestureType: GestureType = .tap()) ->
    GesturePublisher {
        .init(view: self, gestureType: gestureType)
    }
    
    enum GestureType {
        case tap(UITapGestureRecognizer = .init())
        case swipe(UISwipeGestureRecognizer = .init())
        case longPress(UILongPressGestureRecognizer = .init())
        case pan(UIPanGestureRecognizer = .init())
        case pinch(UIPinchGestureRecognizer = .init())
        case edge(UIScreenEdgePanGestureRecognizer = .init())
        func get() -> UIGestureRecognizer {
            switch self {
            case let .tap(tapGesture):
                return tapGesture
            case let .swipe(swipeGesture):
                return swipeGesture
            case let .longPress(longPressGesture):
                return longPressGesture
            case let .pan(panGesture):
                return panGesture
            case let .pinch(pinchGesture):
                return pinchGesture
            case let .edge(edgePanGesture):
                return edgePanGesture
           }
        }
    }
    
    struct GesturePublisher: Publisher {
        typealias Output = GestureType
        typealias Failure = Never
        private let view: UIView
        private let gestureType: GestureType
        init(view: UIView, gestureType: GestureType) {
            self.view = view
            self.gestureType = gestureType
        }
        func receive<S>(subscriber: S) where S : Subscriber,
        GesturePublisher.Failure == S.Failure, GesturePublisher.Output
        == S.Input {
            let subscription = GestureSubscription(
                subscriber: subscriber,
                view: view,
                gestureType: gestureType
            )
            subscriber.receive(subscription: subscription)
        }
    }
    
    class GestureSubscription<S: Subscriber, V: UIView>: Subscription where S.Input == GestureType, S.Failure == Never {
        private var subscriber: S?
        private var gestureType: GestureType
        private var view: V
        init(subscriber: S, view: V, gestureType: GestureType) {
            self.subscriber = subscriber
            self.view = view
            self.gestureType = gestureType
            configureGesture(gestureType)
        }
        private func configureGesture(_ gestureType: GestureType) {
            let gesture = gestureType.get()
            gesture.addTarget(self, action: #selector(handler))
            view.addGestureRecognizer(gesture)
        }
        func request(_ demand: Subscribers.Demand) { }
        func cancel() {
            subscriber = nil
        }
        @objc
        private func handler() {
            _ = subscriber?.receive(gestureType)
        }
    }
    
    
	func addSubviews(_ views: UIView...) {
		views.forEach { addSubview($0) }
	}
	
	// CALayer를 이용하여 UIView의 하단에 줄을 긋는 함수
	func addAboveTheBottomBorderWithColor(color: UIColor) {
		let border = CALayer()
		border.backgroundColor = color.cgColor
		border.frame = CGRect(x: 0, y: self.frame.size.height - 1, width: self.frame.size.width, height: 1)
		self.layer.addSublayer(border)
	}
}
