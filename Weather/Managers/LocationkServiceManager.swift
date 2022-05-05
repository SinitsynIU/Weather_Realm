//
//  LocationManager.swift
//  Weather
//
//  Created by Илья Синицын on 05.04.2022.
//

import CoreLocation
import Foundation

class LocationkServiceManager {
    static let shared = LocationkServiceManager()
    
    let locationManager = CLLocationManager()

    func requestAuthorization(){
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        lat = locValue.latitude
        lon = locValue.longitude
    }
}
