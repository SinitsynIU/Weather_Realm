//
//  TabBarViewController.swift
//  Weather
//
//  Created by Илья Синицын on 24.03.2022.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    private var localized = ["tabBarItem_title_weather", "tabBarItem_title_map", "tabBarItem_title_news","tabBarItem_title_history"]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.unselectedItemTintColor = .darkGray
        self.tabBar.tintColor = .blue
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBar.items?.enumerated().forEach {
            $0.element.title = NSLocalizedString(self.localized[$0.offset], comment: "")
        }
    }
}

