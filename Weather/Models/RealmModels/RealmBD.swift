//
//  RealmBD.swift
//  Weather
//
//  Created by Илья Синицын on 24.05.2022.
//

import RealmSwift
import SwiftUI

class RealmBD: Object {
    
    @Persisted var id: String = UUID().uuidString
    @Persisted var city: String?
    @Persisted var country: String?
    @Persisted var date: Date?
    @Persisted var humidity: Int?
    @Persisted var pressure: Int?
    @Persisted var wind: Double?
    @Persisted var icon: String?
    @Persisted var temp: Double?
    @Persisted var tempMax: Double?
    @Persisted var tempMin: Double?
    @Persisted var lat: Double?
    @Persisted var lon: Double?
    @Persisted var source: String?
    @Persisted var main: String?
    
    convenience init(weather: WeatherJSON, source: SourceValues) {
        self.init()
        
        self.city = weather.name
        self.country = weather.sys.country
        self.date = Date()
        self.humidity = weather.main.humidity
        self.pressure = weather.main.pressure
        self.wind = weather.wind.speed
        self.icon = weather.weather.first?.icon
        self.temp = weather.main.temp
        self.tempMax = weather.main.tempMax
        self.tempMin = weather.main.tempMin
        self.lat = weather.coord.lat
        self.lon = weather.coord.lon
        self.source = source.rawValue
        self.main = weather.weather.first?.main
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    func mappedWeather() -> (WeatherJSON, Date) {
        return (WeatherJSON(coord: Coord(lon: lon ?? 0.0,
                                         lat: lat ?? 0.0),
                            weather: [Weather(main: main ?? "",
                                              icon: icon ?? "",
                                              weatherDescription: "")],
                            main: Main(temp: temp ?? 0.0,
                                         tempMin: tempMin ?? 0.0,
                                         tempMax: tempMax ?? 0.0,
                                       pressure: Int(pressure ?? 0),
                                       humidity: Int(humidity ?? 0)),
                            wind: Wind(speed: wind ?? 0.0),
                            sys: Sys(country: country ?? ""),
                            name: city ?? "",
                            cod: 0),
                            date ?? Date())
    }
}
