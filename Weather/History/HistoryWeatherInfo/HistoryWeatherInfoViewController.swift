//
//  WeatherCurrentViewController.swift
//  Weather
//
//  Created by Илья Синицын on 18.03.2022.
//

import UIKit
import Lottie

class HistoryWeatherInfoViewController: UIViewController {
    
    @IBOutlet weak var closeView: AnimationView?
    @IBOutlet weak var countryCityLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var weatherMainLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var minMaxTempLabel: UILabel!
    
    var weatherJ: RealmBD?

    override func viewDidLoad() {
        super.viewDidLoad()
        closeView?.play()
        setupPlayerVideoBackground(weather: weatherJ, view: view)
        self.overrideUserInterfaceStyle = .light
        //setupUILocalization(weather: weatherJ)
    }
    
    deinit {
        MediaManager.shared.clearMediaPlayer()
        MediaManager.shared.notificationRemove()
    }
    
    private func setupPlayerVideoBackground(weather: RealmBD?, view: UIView) {
        if weather?.main == "Clouds" {
            MediaManager.shared.playerVideoSettings(bundleResource: MediaManager.ResourceBundleValues.clouds, view: view, notificationOn: true)
            MediaManager.shared.playerAudioSettings(bundleResource: .clouds, notificationOn: true)
        } else if weather?.main == "Snow" {
            MediaManager.shared.playerVideoSettings(bundleResource: MediaManager.ResourceBundleValues.snow, view: view, notificationOn: true)
            MediaManager.shared.playerAudioSettings(bundleResource: .wind, notificationOn: true)
        } else if weather?.main == "Rain" {
            MediaManager.shared.playerVideoSettings(bundleResource: MediaManager.ResourceBundleValues.rain, view: view, notificationOn: true)
            MediaManager.shared.playerAudioSettings(bundleResource: .rain, notificationOn: true)
        } else {
            MediaManager.shared.playerVideoSettings(bundleResource: MediaManager.ResourceBundleValues.clear, view: view, notificationOn: true)
            MediaManager.shared.playerAudioSettings(bundleResource: .clear, notificationOn: true)
        }
        MediaManager.shared.playerVideoPlay()
        MediaManager.shared.playerAudioPlay()
    }
    
//    private func setupUILocalization(weather: WeatherDB?) {
//        countryCityLabel.text = "\(weather?.name ?? ""), \(weather?.sys.country ?? "")"
//        tempLabel.text = "\(Int(weather?.main.temp ?? 0))°С"
//        minMaxTempLabel.text = "\(Int(weather?.main.tempMin ?? 0)) min°С / \(Int(weather?.main.tempMax ?? 0)) max°С"
//        weatherMainLabel.text = weather?.weather.first?.weatherDescription ?? ""
//        pressureLabel.text = getLocalizeStringIntString(withString: NSLocalizedString("pressureLabel_text", comment: ""), withInt: (weather?.main.pressure ?? 0), otherString: " hPa")
//        humidityLabel.text = getLocalizeStringIntString(withString: NSLocalizedString("humidityLabel_text", comment: ""), withInt: (weather?.main.humidity ?? 0), otherString: " %")
//        windSpeedLabel.text = getLocalizeStringDoubleString(withString: NSLocalizedString("windSpeedLabel_text", comment: ""), withDouble: (weather?.wind.speed ?? 0), otherString: " m/sec")
//        var icon: String
//        icon = weather?.weather.first?.icon ?? ""
//        FileServiceManager.shared.getWeatherImage(icon: icon, completed: { [weak self] image in
//            self?.weatherImageView.image = image
//        })
 //   }
    
    @IBAction func closeVCTapActions(_ sender: Any) {
        MediaManager.shared.playerAudioSettings(bundleResource: MediaManager.ResourceBundleValues.close, notificationOn: false)
        MediaManager.shared.playerAudioPlay()
        dismiss(animated: true)
    }
}
