//
//
//  MapViewController.swift
//  Weather
//
//  Created by Илья Синицын on 24.03.2022.
//

import UIKit
import MapKit
import GoogleMaps
import CoreLocation
import Lottie

class AppleMapViewController: UIViewController {
    
    @IBOutlet weak var placemarkView: UIView!
    @IBOutlet weak var weatherView: UIView!
    @IBOutlet weak var weatherMyLocation: AnimationView?
    @IBOutlet weak var weatherTemp: UILabel!
    @IBOutlet weak var placemarkCountryLocalityName: UILabel!
    @IBOutlet weak var placemarkSubAdministrativeArea: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var weather: WeatherJSON? = nil
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        mapView.showsUserLocation = true
        mapView.mapType = .standard
        self.overrideUserInterfaceStyle = .light
        weatherView.alpha = 0
        placemarkView.alpha = 0
        weatherMyLocation?.loopMode = .loop
        weatherMyLocation?.play()
    }
    
    private func setupUI(weather: WeatherJSON?) {
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
    
    @IBAction func myLocationTapAction(_ sender: Any) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { _ in
                guard let myLocation = self.locationManager.location?.coordinate else { return }
                self.mapView.setCenter(myLocation, animated: true)
            })
        }
        locationManager.stopUpdatingLocation()
    }
}

extension AppleMapViewController: MKMapViewDelegate {
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        self.weatherMyLocation?.play()
        UIView.animate(withDuration: 0.5) {
            self.weatherView.alpha = 0
            self.placemarkView.alpha = 0
        }
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false, block: { _ in
            self.weatherMyLocation?.pause()
            self.getCoordCityData(lat: mapView.centerCoordinate.latitude, lon: mapView.centerCoordinate.longitude, onCompleted: {
                self.weatherMyLocation?.pause()
                        self.setupUI(weather: self.weather)
                        let geocoder = CLGeocoder()
                        geocoder.reverseGeocodeLocation(CLLocation(
                                        latitude: mapView.centerCoordinate.latitude,
                                        longitude: mapView.centerCoordinate.longitude))                     { placemarks, error in
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

extension AppleMapViewController: CLLocationManagerDelegate {
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
                locationManager.startUpdatingLocation()
            }
        }
}
