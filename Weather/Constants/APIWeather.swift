//
//  API.swift
//  Weather
//
//  Created by Илья Синицын on 18.03.2022.
//
//https://api.openweathermap.org/data/2.5/weather?lat=37.785834&lon=-122.406417&appid=5ca646e9fd1af628a47ff1d2d797f930&units=metric
//
//https://api.openweathermap.org/data/2.5/weather?q=Moskow&appid=5ca646e9fd1af628a47ff1d2d797f930&units=metric
//

import Foundation

enum APIWeather: String {
    
    case APIkey = "5ca646e9fd1af628a47ff1d2d797f930&units=metric&lang=ru"
    
    case host = "https://api.openweathermap.org/"
    
    case coordinate = "data/2.5/weather?lat=%@&lon=%@&appid="
    
    case city = "data/2.5/weather?q=%@&appid="
    
    case icon = "http://openweathermap.org/img/wn/%@@2x.png"
    
    var url: URL? {
        return URL(string: APIWeather.host.rawValue + self.rawValue + APIWeather.APIkey.rawValue)
    }
    
    func getCityURL(city: String) -> URL? {
        let string = APIWeather.host.rawValue + self.rawValue + APIWeather.APIkey.rawValue
        let newString = String(format: string, city)
        return URL(string: newString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
    }
    
    func getCoordCityURL(lat: String, lon: String) -> URL? {
        let string = APIWeather.host.rawValue + self.rawValue + APIWeather.APIkey.rawValue
        let newString = String(format: string, lat, lon)
        return URL(string: newString)
    }
    
    func getIconURL(icon: String) -> URL? {
        let string =  APIWeather.icon.rawValue
        let newString = String(format: string, icon)
        return URL(string: newString)
    }
}
