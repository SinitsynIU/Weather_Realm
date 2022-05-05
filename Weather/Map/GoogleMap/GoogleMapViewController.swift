//
//  GoogleMapViewController.swift
//  Weather
//
//  Created by Илья Синицын on 07.04.2022.
//

import UIKit
import GoogleMaps
import CoreLocation

class GoogleMapViewController: UIViewController {
    
    @IBOutlet weak var placemarkView: UIView!
    @IBOutlet weak var weatherView: UIView!
    @IBOutlet weak var weatherTemp: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var placemarkCountryLocalityName: UILabel!
    @IBOutlet weak var placemarkSubAdministrativeArea: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    
    let locationManager = CLLocationManager()
    var weather: WeatherJSON? = nil
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("google Map")
        setupUIStart()
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        mapView.delegate = self
        mapView.delegate = self
    }
    
    private func setupUIStart() {
        self.overrideUserInterfaceStyle = .light
        weatherView.alpha = 0
        placemarkView.alpha = 0
        mapView.isMyLocationEnabled = true
        mapView.mapType = .normal
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true
        mapView.settings.zoomGestures = true
        mapView.settings.tiltGestures = false
        mapView.settings.rotateGestures = false
        mapView.settings.scrollGestures = true
    }
    
    private func setupUI(weather: WeatherJSON?) {
        weatherView.alpha = 0
        placemarkView.alpha = 0
        mapView.isMyLocationEnabled = true
        mapView.mapType = .normal
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true
        //mapView.settings.scrollGestures = false
        UIView.animate(withDuration: 0.5) {
            self.weatherView.alpha = 1
            self.placemarkView.alpha = 1
        }
        weatherView.layer.cornerRadius = 20
        placemarkView.layer.cornerRadius = 20
        weatherTemp.text = "\(Int(weather?.main.temp ?? 0))°С"
        let icon: String = weather?.weather.first?.icon ?? ""
            FileServiceManager.shared.getWeatherImage(icon: icon, completed: { [weak self] image in
                self?.weatherImage.image = image
            })
    }
    
    private func getCoordCityData(lat: Double?, lon: Double?, onCompleted: @escaping(() -> ())) {
        NetworkServiceManager.shared.getWeatherCoordCityJSON(lat: lat, lon: lon) { [weak self] (result) in
            switch result {
            case .success(let weatherJSON):
                
                CoreDataManager.shared.addWeather(weather: weatherJSON, source: SourceValues.coordinate)
                
                self?.weather = weatherJSON
                //print("weatherJSON", weatherJSON)
            case .failure(let error):
                self?.showAlert(with: "\(error.localizedDescription)")
            }
            onCompleted()
        }
    }
}

extension GoogleMapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        UIView.animate(withDuration: 0.5) {
            self.weatherView.alpha = 0
            self.placemarkView.alpha = 0
        }
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false, block: { _ in
            self.getCoordCityData(lat: position.target.latitude, lon: position.target.longitude, onCompleted: {
                    self.setupUI(weather: self.weather)
                    let geocoder = CLGeocoder()
                    geocoder.reverseGeocodeLocation(CLLocation(
                        latitude: position.target.latitude,
                        longitude: position.target.longitude)) { placemarks, error in
                            if let error = error {
                                print(error.localizedDescription)
                }
                    guard let placemark = placemarks?.first else { return }
                            self.placemarkCountryLocalityName.text = "\(placemark.country ?? "unknown"), \(placemark.locality ?? "unknown"), \(placemark.name ?? "unknown")"
                            self.placemarkSubAdministrativeArea.text = "\(placemark.administrativeArea ?? "unknown")"
                    }
            })
        })
    }
}
