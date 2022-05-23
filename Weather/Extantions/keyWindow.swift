//
//  keyWindow.swift
//  Weather
//
//  Created by Илья Синицын on 23.05.2022.
//

import UIKit

extension UIApplication {
    
    var keyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .compactMap({$0 as? UIWindowScene})
                .first?.windows
                .filter({$0.isKeyWindow}).first
    }
}
