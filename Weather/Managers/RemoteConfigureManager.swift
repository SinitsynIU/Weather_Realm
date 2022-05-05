//
//  RemoteConfigManager.swift
//  Weather
//
//  Created by Илья Синицын on 07.04.2022.
//

import FirebaseRemoteConfig
import UIKit

enum ValueKey: String {
    case showNews
    case mapType
}

class RemoteConfigureManager {
    static let shared = RemoteConfigureManager()
    
    init () {
        loadDefaultValues()
    }
    
    private func loadDefaultValues() {
        let defaultValue: [String: Any?] = [
            ValueKey.showNews.rawValue: true,
            ValueKey.mapType.rawValue: "apple"
        ]
        RemoteConfig.remoteConfig().setDefaults(defaultValue as? [String: NSObject])
    }
    
    func connectToFirebase(_ onCompleted: @escaping(() -> ())) {
        RemoteConfig.remoteConfig().fetch(withExpirationDuration: 0) { status, error in
            if let error = error {
                print(error.localizedDescription)
                onCompleted()
                return
            }
            RemoteConfig.remoteConfig().activate() { _, _ in
                onCompleted()
            }
        }
    }
    
    func stringForKey(key: ValueKey) -> String? {
        return RemoteConfig.remoteConfig()[key.rawValue].stringValue
    }
    
    func boolForKey(key: ValueKey) -> Bool {
        return RemoteConfig.remoteConfig()[key.rawValue].boolValue
    }
}
