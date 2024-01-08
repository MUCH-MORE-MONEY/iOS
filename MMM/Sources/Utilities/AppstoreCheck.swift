//
//  AppstoreCheck.swift
//  MMM
//
//  Created by yuraMacBookPro on 1/8/24.
//

import UIKit
import FirebaseRemoteConfig

final class AppstoreCheck {
    // 앱 자체 버전
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    static let appStoreopenUrlString = "itms-apps://itunes.apple.com/app/apple-store/6450030412"
    
    // 앱스토어의 버전 체크
    func latestVersion() -> String? {
        let appleID = "6450030412"
        guard let url = URL(string: "http://itunes.apple.com/lookup?id=\(appleID)&country=kr"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
              let results = json["results"] as? [[String: Any]],
              let appStoreVersion = results[0]["version"] as? String else {
            return nil
        }
        return appStoreVersion
    }
    
    // remoteConfig의 버전
    func latestVersionByFirebase() async throws -> (String?, Bool?) {
        let remoteConfig = RemoteConfig.remoteConfig()
        
        do {
            let status = try await remoteConfig.fetch()
            if status == .success {
                _ = try await remoteConfig.activate()
                return (remoteConfig["minimum_version"].stringValue, remoteConfig["force_update"].boolValue)
            } else {
                return (nil, nil)
            }
        } catch {
            throw error
        }
    }
    

    func openAppStore() {
        guard let url = URL(string: AppstoreCheck.appStoreopenUrlString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
