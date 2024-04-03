//
//  Ex+UserDefaults.swift
//  MMM
//
//  Created by geonhyeong on 2023/06/07.
//

import Foundation
import RxSwift

extension UserDefaults {
	static var shared: UserDefaults {
		// 1. App Groups Identifier 를 저장하는 변수
		let appGroupID = "group.labM.project.MMM"

		// 2. 파라미터로 전달되는 이름의 기본값으로 초기화된 UserDefaults 개체를 만든다.
		// 3. 이전까지 사용했던 standard UserDefaults 와 다르다. 공유되는 App Group Container 에 있는 저장소를 사용한다.
		// 4. suitename : The domain identifier of the search list.
		return UserDefaults(suiteName: appGroupID)!
	}
    
    func observe<T>(key: String, defaultValue: T) -> Observable<T> {
        return Observable.create { observer in
            let defaults = UserDefaults.standard
            observer.onNext(defaults.object(forKey: key) as? T ?? defaultValue)
            
            let notificationCenter = NotificationCenter.default
            let observer = notificationCenter.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: nil) { notification in
                if let defaults = notification.object as? UserDefaults {
                    observer.onNext(defaults.object(forKey: key) as? T ?? defaultValue)
                }
            }
            
            return Disposables.create {
                notificationCenter.removeObserver(observer)
            }
        }
    }
}
