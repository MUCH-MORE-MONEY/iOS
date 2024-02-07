//
//  SceneDelegate.swift
//  MMM
//
//  Created by geonhyeong on 2023/03/28.
//

import UIKit
import FirebaseRemoteConfig
import StoreKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	
	var window: UIWindow?
	var onboarding: OnboardingViewController!
	
	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		// Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
		// If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
		// This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
		guard let windowScene = (scene as? UIWindowScene) else { return }
		
		window = UIWindow(windowScene: windowScene)
		
		onboarding = OnboardingViewController()
		var mainViewController: UIViewController

		// 로그인이 되어 있을 경우
        
		if let token = Constants.getKeychainValue(forKey: Constants.KeychainKey.token) {
            if let email = Constants.getKeychainValue(forKey: Constants.KeychainKey.email) {
                Tracking.setUser(email)
            }
			if let url = connectionOptions.urlContexts.first?.url { // 위젯
				switch url.absoluteString {
				case "myApp://Add": // 추가 위젯
                    Tracking.Widget.btnFinActAddLogEvent()
					mainViewController = NavigationController(rootViewController: TabBarController(widgetIndex: 1))
				default: // widgetURL을 설정한 다른 위젯
                    Tracking.Widget.btnMonthLogEvent()
					mainViewController = NavigationController(rootViewController: TabBarController(widgetIndex: 0))
				}
			} else { // 일반 진입
				mainViewController = NavigationController(rootViewController: TabBarController(widgetIndex: 0))
			}
		} else {
			mainViewController = onboarding
		}
		
		// 화면에 띄울 Root 뷰 컨트롤러 지정
		window?.rootViewController = mainViewController

		// Window의 Background Color설정.
		// window 또는 ViewController의 backgroundColor중 하나는 설정되어야합니다.
		// 둘중 하나 미설정시 검은화면만 보입니다.
		window?.backgroundColor = .systemBackground

		window?.makeKeyAndVisible()
	}
    
	// background 에서 foreground 로 진입
	func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
		guard let url = URLContexts.first?.url else { return }
		
		if "myApp://Home" == url.absoluteString {
            Tracking.Widget.btnMonthLogEvent()
			let mainViewController = NavigationController(rootViewController: TabBarController(widgetIndex: 0))
			window?.rootViewController = mainViewController
		} else if "myApp://Add" == url.absoluteString {
            Tracking.Widget.btnFinActAddLogEvent()
			let mainViewController = NavigationController(rootViewController: TabBarController(widgetIndex: 1))
			window?.rootViewController = mainViewController
		}
	}
	
	func sceneDidDisconnect(_ scene: UIScene) {
		// Called as the scene is being released by the system.
		// This occurs shortly after the scene enters the background, or when its session is discarded.
		// Release any resources associated with this scene that can be re-created the next time the scene connects.
		// The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
	}
	
	func sceneDidBecomeActive(_ scene: UIScene) {
		// Called when the scene has moved from an inactive state to an active state.
		// Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
	}
	
	func sceneWillResignActive(_ scene: UIScene) {
		// Called when the scene will move from an active state to an inactive state.
		// This may occur due to temporary interruptions (ex. an incoming phone call).
	}
	
    // 앱을 들어왔을 경우 badge 초기화
	func sceneWillEnterForeground(_ scene: UIScene) {
        checkAndUpdateIfNeeded()
        UIApplication.shared.applicationIconBadgeNumber = 0
	}
	
	func sceneDidEnterBackground(_ scene: UIScene) {
		// Called as the scene transitions from the foreground to the background.
		// Use this method to save data, release shared resources, and store enough scene-specific state information
		// to restore the scene back to its current state.
	}
}

extension SceneDelegate {
    // 업데이트가 필요한지 확인하는 함수
     func checkAndUpdateIfNeeded() {
         // 현재 앱스토어에 있는 버전
         DispatchQueue.main.async { [weak self] in
             guard let self = self else { return }
             Task {
                 do {
                     let data = try await AppstoreCheck().latestVersionByFirebase()
                     guard let version = data.0, let forceUpdate = data.1 else { return }
                     
                     let deferredVersion = Common.getDefferedVersion()
                     
                     print("remote config version : \(version)")
                     print("forceUpdate : \(forceUpdate)")
                     let remoteVersion = version
                     
            //          현재 프로젝트의 버전
                     let currentProjectVersion = AppstoreCheck.appVersion ?? ""
                     
                     // 앱스토어에 있는 버전을 .마다 나눈 것 (예: 1.2.1 버전이라면 [1, 2, 1])
                     let splitMarketingVersion = remoteVersion.split(separator: ".").map { $0 }
                     
                     // 현재 프로젝트 버전을 .마다 나눈 것
                     let splitCurrentProjectVersion = currentProjectVersion.split(separator: ".").map { $0 }
                     
                     // 강제 업데이트 유무
                     if forceUpdate {
                         self.showUpdateAlert(version: remoteVersion)
                     }
                     // Major 버전 비교
                     else if splitCurrentProjectVersion[0] < splitMarketingVersion[0] {
                         let splitDeferredVersion = deferredVersion.split(separator: ".").map { $0 }
                         if splitDeferredVersion[0] < splitMarketingVersion[0] {
                             self.showUpdateAlert(version: remoteVersion)
                         }
                         
                     // Minor 비전 비교
                     } else if splitCurrentProjectVersion[1] < splitMarketingVersion[1] {
                         let splitDeferredVersion = deferredVersion.split(separator: ".").map { $0 }
                         if splitDeferredVersion[1] < splitMarketingVersion[1] {
                             self.showUpdateAlert(version: remoteVersion)
                         }
                         
                     // 나머지 상황에서는 업데이트 알럿을 띄우지 않음(patch)
                     } else {
                         Common.setDeferredVersion(version)
                         debugPrint("현재 최신 버전입니다.")
                     }
                     
                 } catch {
                     debugPrint("Error \(error)")
                 }
             }
         }
     }
     
    // 알럿을 띄우는 함수
    func showUpdateAlert(version: String) {
        let alert = UIAlertController(
            title: "업데이트 알림",
            message: "\(version)으로의 업데이트 사항이 있습니다. 앱스토어에서 앱을 업데이트 해주세요.",
            preferredStyle: .alert
        )
        
        // 업데이트 버튼을 누르면 앱스토어로 이동
        let updateAction = UIAlertAction(title: "업데이트", style: .default) { _ in
            AppstoreCheck().openAppStore()
        }
        // "나중에" 버튼을 누를 경우 현재 remoteConfig version을 저장
        let laterAction = UIAlertAction(title: "나중에", style: .default) { _ in
            Common.setDeferredVersion(version)
        }
        
        alert.addAction(updateAction)
        alert.addAction(laterAction)
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}
