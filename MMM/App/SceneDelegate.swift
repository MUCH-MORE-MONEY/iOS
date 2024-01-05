//
//  SceneDelegate.swift
//  MMM
//
//  Created by geonhyeong on 2023/03/28.
//

import UIKit
import FirebaseRemoteConfig

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

        
        checkAppVersion()
        
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
        UIApplication.shared.applicationIconBadgeNumber = 0
	}
	
	func sceneDidEnterBackground(_ scene: UIScene) {
		// Called as the scene transitions from the foreground to the background.
		// Use this method to save data, release shared resources, and store enough scene-specific state information
		// to restore the scene back to its current state.
	}
}

extension SceneDelegate {
    // remoteConfig를 이용하여 앱 버전 체크 및 업데이트 유무를 결정하는 함수
    private func checkAppVersion() {
        let remoteConfig = RemoteConfig.remoteConfig()
        remoteConfig.fetch { status, error in
            if status == .success {
                remoteConfig.activate { changed, error in
                    self.compareVersion(remoteConfig: remoteConfig)
                }
            } else if let error = error {
                print("Error fetching remote config: \(error.localizedDescription)")
            }
        }
    }
    
    private func compareVersion(remoteConfig: RemoteConfig) {
        let minimumVersionString = remoteConfig["minimum_version"].stringValue ?? "1.0.0"
        let currentVersionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
        print("서버 버전 : \(minimumVersionString)")
        print("현재 버전 : \(currentVersionString)")
        
        
        if currentVersionString.compare(minimumVersionString, options: .numeric) == .orderedAscending {
            // 현재 버전이 서버에 설정된 최소 버전보다 낮은 경우
            DispatchQueue.main.async {
                self.promptForUpdate()
            }
        } else {
            print("버전 같음")
        }
    }
    
    private func promptForUpdate() {
        let alert = UIAlertController(title: "Update Available", message: "A new version of the app is available. Please update to continue.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { _ in
            // 앱스토어로 리디렉션하거나 업데이트 관련 처리
            print("Redirection to appstore")
        }))
        window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}
