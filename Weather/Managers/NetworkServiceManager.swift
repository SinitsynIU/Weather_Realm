//
//  NetworkServiceManager.swift
//  Weather
//
//  Created by Илья Синицын on 18.03.2022.
//

import Foundation
import Alamofire

class NetworkServiceManager {
    static let shared = NetworkServiceManager()
    
    func getWeatherCityJSON(city: String, completion: @escaping (Result<WeatherJSON, Error>) -> Void) {
        guard let url = APIWeather.city.getCityURL(city: city) else { return }
        AF.request(url, method: .get)
            .responseDecodable(of: WeatherJSON.self) { response in
                switch response.result {
                case .success(let weatherJson):
                    DispatchQueue.main.async {
                        completion(.success(weatherJson))
                    }
                case .failure(let error):
                    completion(.failure(error))
                    print("Failed to decode JSON, \(error.localizedDescription)")
                }
        }
    }
    
    func getWeatherCoordCityJSON(lat: Double?, lon: Double?, completion: @escaping (Result<WeatherJSON, Error>) -> Void) {
        let a: String = String(format: "%f", lat ?? 0)
        let b: String = String(format: "%f", lon ?? 0)
        guard let url = APIWeather.coordinate.getCoordCityURL(lat: a, lon: b) else { return }
        print(url)
        AF.request(url, method: .get)
            .responseDecodable(of: WeatherJSON.self) { response in
                switch response.result {
                case .success(let weatherJson):
                    DispatchQueue.main.async {
                        completion(.success(weatherJson))
                    }
                case .failure(let error):
                    completion(.failure(error))
                    print("Failed to decode JSON, \(error.localizedDescription)")
                }
        }
    }
    
    func getNewsJSON(search: String, completion: @escaping (Result<NewsJSON, Error>) -> Void) {
        guard let url = APINews.host.getNewsURL(search: search) else { return }
        AF.request(url, method: .get)
            .responseDecodable(of: NewsJSON.self) { response in
                switch response.result {
                case .success(let weatherJson):
                    DispatchQueue.main.async {
                        completion(.success(weatherJson))
                    }
                case .failure(let error):
                    completion(.failure(error))
                    print("Failed to decode JSON, \(error.localizedDescription)")
                }
        }
    }
    
    func getNewsCountryJSON(completion: @escaping (Result<NewsJSON, Error>) -> Void) {
        guard let url = APINews.country.getNewsCountryURL() else { return }
        AF.request(url, method: .get)
            .responseDecodable(of: NewsJSON.self) { response in
                switch response.result {
                case .success(let weatherJson):
                    DispatchQueue.main.async {
                        completion(.success(weatherJson))
                    }
                case .failure(let error):
                    completion(.failure(error))
                    print("Failed to decode JSON, \(error.localizedDescription)")
                }
        }
    }
}
