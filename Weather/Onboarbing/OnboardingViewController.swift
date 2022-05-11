//
//  OnboardingViewController.swift
//  Weather
//
//  Created by Илья Синицын on 07.04.2022.
//

import UIKit
import NVActivityIndicatorView
import AVFoundation

class OnboardingViewController: UIViewController {
    
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    @IBOutlet weak var loadingLabel: UILabel!
    
    let group = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light
        activityIndicatorView.startAnimating()
        
        MediaManager.shared.playerAudioSettings(bundleResource: MediaManager.ResourceBundleValues.loading, notificationOn: false)
        MediaManager.shared.playerVideoSettings(bundleResource: MediaManager.ResourceBundleValues.loading, view: view, notificationOn: false)
        MediaManager.shared.playerAudioPlay()
        MediaManager.shared.playerVideoPlay()
        
        group.enter()
        RemoteConfigureManager.shared.connectToFirebase { [weak self] in
            self?.group.leave()
        }
       
        group.notify(queue: .main) { [weak self] in
            self?.stopAnimations()
            self?.configureTabBarController()
        }
    }
    
    deinit {
        MediaManager.shared.clearMediaPlayer()
    }
    
    private func stopAnimations() {
        activityIndicatorView.stopAnimating()
        UIView.animate(withDuration: 0.5){
            self.loadingLabel.alpha = 0
        }
    }
    
    private func configureTabBarController() {
        guard let tabBarVC = TabBarViewController.getInstanceViewController as? TabBarViewController,
              var viewControllers = tabBarVC.viewControllers,
              let keyWindow = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .compactMap({$0 as? UIWindowScene})
                .first?.windows
                .filter({$0.isKeyWindow}).first
            else {return}
        
        if RemoteConfigureManager.shared.stringForKey(key: .mapType) ==  defaultValue.apple.rawValue {
            if let appleMapVC = AppleMapViewController.getInstanceViewController {
                viewControllers.append(appleMapVC)
            }
        } else {
            if let googleMapVC = GoogleMapViewController.getInstanceViewController {
                viewControllers.append(googleMapVC)
            }
        }
        
        if RemoteConfigureManager.shared.boolForKey(key: .showNews) {
            if let newsVC = SearchNewsViewController.getInstanceViewController {
                viewControllers.append(newsVC)
            }
        }
        
        if let historyVC = HistoryViewController.getInstanceViewController {
            viewControllers.append(historyVC)
        }
        
        tabBarVC.viewControllers = viewControllers
        keyWindow.rootViewController = tabBarVC
        keyWindow.makeKeyAndVisible()
    }
}
