//
//  AdsManager.swift
//  Weather
//
//  Created by Илья Синицын on 12.05.2022.
//

import GoogleMobileAds

class AdsManager: NSObject {
    static let shared = AdsManager()
    
    var interstitial: GADInterstitialAd?
    var rewardedAd: GADRewardedAd?
    var timer: Timer?
    
    func setupBunner(bannerView: GADBannerView, viewController: UIViewController) {
        // my banner ID = ca-app-pub-2048459780354579/2926760059
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = viewController
        bannerView.load(GADRequest())
    }
    
    func setupInterstitial(onError: @escaping(() -> ())) {
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: false, block: { _ in
            let request = GADRequest()
                // my interstitial ID = ca-app-pub-2048459780354579/5361351703
                GADInterstitialAd.load(withAdUnitID:"ca-app-pub-3940256099942544/4411468910",
                                        request: request,
                              completionHandler: { [self] ad, error in
                                if let error = error {
                                  print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                                    onError()
                                  return
                                }
                                interstitial = ad
                                interstitial?.fullScreenContentDelegate = self
                                guard let controller = UIApplication.shared.topViewController() else { return }
                                interstitial?.present(fromRootViewController: controller)
                              })
        })
    }
    
    func setupRewarded(viewController: UIViewController, onCompleted: @escaping(() -> ()), onError: @escaping(() -> ())) {
        let request = GADRequest()
        // my reward ID = ca-app-pub-2048459780354579/7795943351
        GADRewardedAd.load(withAdUnitID:"ca-app-pub-3940256099942544/1712485313",
                            request: request,
                            completionHandler: { [self] ad, error in
             if let error = error {
               print("Failed to load rewarded ad with error: \(error.localizedDescription)")
                 onError()
               return
             }
             ad?.present(fromRootViewController: viewController) {
                 print("Reward")
                 onCompleted()
            }
            rewardedAd = ad
            print("Rewarded ad loaded.")
            rewardedAd?.fullScreenContentDelegate = viewController as? GADFullScreenContentDelegate
           })
    }
}

extension AdsManager: GADFullScreenContentDelegate {
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        timer?.invalidate()
        setupInterstitial {
            print("Failed to load rewarded ad with error")
        }
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        timer?.invalidate()
        setupInterstitial {
            print("Failed to load rewarded ad with error")
        }
    }
}

extension UIApplication {
    
    func topViewController (controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
