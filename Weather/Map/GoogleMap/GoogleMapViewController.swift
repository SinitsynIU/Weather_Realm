//
//  GoogleMapViewController.swift
//  Weather
//
//  Created by Илья Синицын on 07.04.2022.
//

import UIKit
import GoogleMaps
import CoreLocation
import RxCocoa
import RxSwift

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
    let disposeBag = DisposeBag()
    var subjectOnMap: BehaviorSubject<CLLocationCoordinate2D>? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUIStart()
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        mapView.delegate = self
        getDataOnMap()
    }
    
    private func getDataOnMap() {
        subjectOnMap?
            .debounce(DispatchTimeInterval.seconds(2), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] value in
                guard let self = self else { return }
                self.getCoordCityData(lat: value.latitude, lon: value.longitude, onCompleted: {
                        self.setupUI(weather: self.weather)
                        let geocoder = CLGeocoder()
                        geocoder.reverseGeocodeLocation(CLLocation(
                            latitude: value.latitude,
                            longitude: value.longitude)) { placemarks, error in
                                if let error = error {
                                    print(error.localizedDescription)
                        }
                        guard let placemark = placemarks?.first else { return }
                                self.placemarkCountryLocalityName.text = "\(placemark.country ?? "unknown"), \(placemark.locality ?? "unknown"), \(placemark.name ?? "unknown")"
                                self.placemarkSubAdministrativeArea.text = "\(placemark.administrativeArea ?? "unknown")"
                        }
                })
            }).disposed(by: disposeBag)
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
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.weatherView.alpha = 1
            self?.placemarkView.alpha = 1
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
                RealmManager.shared.addWeather(weather: weatherJSON, source: SourceValues.coordinate)
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
        UIView.animate(withDuration: 0.5) { [weak self] in
            guard let self = self else { return }
            self.weatherView.alpha = 0
            self.placemarkView.alpha = 0
        }
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let coordinates = CLLocationCoordinate2D(latitude: position.target.latitude, longitude: position.target.longitude)
            if self.subjectOnMap == nil {
                self.subjectOnMap = BehaviorSubject<CLLocationCoordinate2D>(value: coordinates)
                self.getDataOnMap()
            } else {
                self.subjectOnMap?.onNext(coordinates)
            }
        }
    }
}
