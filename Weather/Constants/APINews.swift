//
//  APINews.swift
//  Weather
//
//  Created by Илья Синицын on 24.03.2022.
//https://newsapi.org/v2/everything?q=Kurgan&apiKey=abe1a2ba918a4f679fb97f865061455d
//
//https://newsapi.org/v2/top-headlines?country=ru&apiKey=abe1a2ba918a4f679fb97f865061455d

import Foundation

enum APINews: String {
    
    case APIkey = "&apiKey=abe1a2ba918a4f679fb97f865061455d"
    
    case host = "https://newsapi.org/v2/everything?q=%@"
    
    case country = "https://newsapi.org/v2/top-headlines?country=ru"
    var url: URL? {
        return URL(string: APINews.host.rawValue + APINews.APIkey.rawValue)
    }
    
    var countruUrl: URL? {
        return URL(string: APINews.country.rawValue + APINews.APIkey.rawValue)
    }
    
    func getNewsURL(search: String) -> URL? {
        let string = APINews.host.rawValue + APINews.APIkey.rawValue
        let newString = String(format: string, search)
        return URL(string: newString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
    }
    
    func getNewsCountryURL() -> URL? {
        let string = APINews.country.rawValue + APINews.APIkey.rawValue
        let newString = String(format: string)
        return URL(string: newString)
    }
    
    
}
