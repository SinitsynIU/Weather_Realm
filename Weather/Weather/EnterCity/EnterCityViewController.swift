//
//  EnterCityViewController.swift
//  Weather
//
//  Created by Илья Синицын on 17.03.2022.
//
import CoreLocation
import UIKit
import NVActivityIndicatorView
import Lottie

class EnterCityViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var blur: UIVisualEffectView!
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    @IBOutlet weak var buttonOk: ButtonCustom!
    @IBOutlet weak var buttonCurrentLocation: ButtonCustom!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var enterCityTextField: UITextField!
    
    var weather: WeatherJSON? = nil
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.hideKeyboardWhenTappedAround()
        setupUI()
        setupLocalization()
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.stopUpdatingLocation()
    }
    
    func getCityData(city: String, onCompleted: @escaping(() -> ())) {
        NetworkServiceManager.shared.getWeatherCityJSON(city: city) { [weak self] (result) in
            switch result {
            case .success(let weatherJSON):
                RealmManager.shared.addWeather(weather: weatherJSON, source: SourceValues.city)
                self?.weather = weatherJSON
                //print("weatherJSON", weatherJSON)
            case .failure(let error):
                self?.showAlert(with: "\(error.localizedDescription)")
            }
            onCompleted()
        }
    }
    
    func getCoordCityData(lat: Double?, lon: Double?, onCompleted: @escaping(() -> ())) {
        NetworkServiceManager.shared.getWeatherCoordCityJSON(lat: lat, lon: lon) { [weak self] (result) in
            switch result {
            case .success(let weatherJSON):
                RealmManager.shared.addWeather(weather: weatherJSON, source: SourceValues.coordinate)
                self?.weather = weatherJSON
                //print("weatherJSON", weatherJSON)
            case .failure(let error):
                self?.showAlert(with: "\(error.localizedDescription)")
            }
            onCompleted()
        }
    }
    
    private func setupUI() {
        self.overrideUserInterfaceStyle = .light
        enterCityTextField.layer.cornerRadius = 25
        enterCityTextField.layer.borderWidth = 1
        blur.isHidden = true
        blurView.center = view.center
    }
    
    private func setupLocalization() {
        weatherLabel.text = NSLocalizedString("tabBarItem_title_weather", comment: "")
        enterCityTextField.placeholder = NSLocalizedString("enterCityTextField_placeholder", comment: "")
        orLabel.text = NSLocalizedString("orLabel_text", comment: "")
        buttonCurrentLocation.textLabel.text = NSLocalizedString("useCurrentLocationButton_titleLabel", comment: "")
    }
    
    @IBAction func okButtonTapAction(_ sender: Any) {
        MediaManager.shared.playerAudioSettings(bundleResource: MediaManager.ResourceBundleValues.click, notificationOn: false)
        MediaManager.shared.playerAudioPlay()
        if CLLocationManager.locationServicesEnabled() {
            activityIndicatorView.startAnimating()
            locationManager.startUpdatingLocation()
            blur.isHidden = false
            getCityData(city: enterCityTextField.text ?? "") { [weak self] in
                if self?.weather?.cod == 200 {
                        self?.activityIndicatorView.stopAnimating()
                        self?.enterCityTextField.text = nil
                        self?.blur.isHidden = true
                        self?.pushWeatherCurrentViewController()
                } else {
                    self?.activityIndicatorView.stopAnimating()
                    self?.blur.isHidden = true
                    self?.showAlert(with: NSLocalizedString("showAlertOkButtonTap", comment: ""))
                }
            }
        }
    }
    
    @IBAction func currentLocationButtonTapAction(_ sender: Any) {
        MediaManager.shared.playerAudioSettings(bundleResource: MediaManager.ResourceBundleValues.click, notificationOn: false)
        MediaManager.shared.playerAudioPlay()
        if CLLocationManager.locationServicesEnabled() {
            activityIndicatorView.startAnimating()
            locationManager.startUpdatingLocation()
            blur.isHidden = false
            getCoordCityData(lat: locationManager.location?.coordinate.latitude, lon: locationManager.location?.coordinate.longitude) { [weak self] in
                if self?.weather?.cod == 200 {
                        self?.activityIndicatorView.stopAnimating()
                        self?.enterCityTextField.text = nil
                        self?.pushWeatherCurrentViewController()
                } else {
                    self?.activityIndicatorView.stopAnimating()
                    self?.blur.isHidden = true
                    self?.showAlert(with: NSLocalizedString("showAlertCurrentLocButtonTap", comment: ""))
                }
            }
        }
    }
    
    private func pushWeatherCurrentViewController() {
        guard let vc = WeatherCurrentViewController.getInstanceViewController as? WeatherCurrentViewController else { return }
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .flipHorizontal
            vc.weatherJ = weather
            present(vc, animated: true, completion: { [weak self] in
                self?.blur.isHidden = true
            })
    }
}
