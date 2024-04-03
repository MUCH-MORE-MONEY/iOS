//
//  Ex+UITextView.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/05/24.
//

import UIKit
import Combine

extension UITextView {
    private struct AssociatedKeys {
        static var textPublisher = "textPublisher"
    }
    
    var textPublisher: AnyPublisher<(String, Int), Never> {
        if let publisher = objc_getAssociatedObject(self, &AssociatedKeys.textPublisher) as? AnyPublisher<(String, Int), Never> {
            return publisher
        }
        
        let publisher = TextViewPublisher(textView: self).eraseToAnyPublisher()
        objc_setAssociatedObject(self, &AssociatedKeys.textPublisher, publisher, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return publisher
    }
}

class TextViewPublisher: NSObject, UITextViewDelegate, Publisher {
    typealias Output = (String, Int)
    typealias Failure = Never
    
    private let textView: UITextView
    private var subscriber: AnySubscriber<Output, Failure>?
    
    init(textView: UITextView) {
        self.textView = textView
        super.init()
        
        self.textView.delegate = self
    }
    
    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        self.subscriber = AnySubscriber(subscriber)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        _ = subscriber?.receive((textView.text, 0))
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        _ = subscriber?.receive((textView.text, 1))
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        _ = subscriber?.receive((textView.text, 2))
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder() // 키보드 내리기
            return false
        }
        return true
        _ = subscriber?.receive((textView.text, 3))
    }
}
