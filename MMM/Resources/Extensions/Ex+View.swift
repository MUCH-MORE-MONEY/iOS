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
    /// UIView를 상속받는 클래스의 tap Gesture Publisher
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
    
    class GesturePublisher: Publisher {
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
	func addAboveTheBottomBorderWithColor(color: UIColor, padding: CGFloat = 20) {
		let border = CALayer()
		border.backgroundColor = color.cgColor
		border.frame = CGRect(x: padding, y: self.frame.size.height - 1, width: self.frame.size.width - padding * 2, height: 1)
		self.layer.addSublayer(border)
	}
	
	// 특정 텍스트 필드의 x축 값을 변경하는 애니메이션 함수
	func shake() {
		let animation = CAKeyframeAnimation(keyPath: "position.x")
		animation.values = [0, 10, -10, 10, 0] // x축 상수 값이 원점, 왼쪽, 오른쪽, 왼쪽, 원점으로 이어짐
		animation.keyTimes = [0, 0.08, 0.24, 0.415, 0.5]
		animation.duration = 0.5
		animation.fillMode = .forwards
		animation.isRemovedOnCompletion = false
		animation.isAdditive = true // 현재 주어진 텍스트 필드의 위치에 해당 x값이 추가되는 구조
		layer.add(animation, forKey: nil)
	}
}
