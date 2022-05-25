//
//  NetworkServiceManager.swift
//  Weather
//
//  Created by Илья Синицын on 18.03.2022.
//

import RealmSwift
import Combine

enum SourceValues: String {
    case city
    case coordinate
}

class RealmManager {
    enum RealmCodesError: Int {
        case removed = 1
        case migration = 10
    }
    
    static let shared = RealmManager()
    
    private let dataBaseName = "default.realm"
    private var version: UInt64 {
        set {
            UserDefaults.standard.set(newValue, forKey: "versionRealm")
        }
        
        get {
            return UInt64((UserDefaults.standard.object(forKey: "versionRealm") as? Int) ?? 1)
        }
    }
    
    private var dataBasePath: URL {
        return FileServiceManager.shared.documentDirectory.appendingPathComponent(self.dataBaseName)
    }
    
    private lazy var realm: Realm = {
        do {
            return try initRealm()
        } catch(let e) {
            guard let error = RealmCodesError(rawValue: (e as NSError).code) else { return try! initRealm() }
            
            switch error {
            case .migration: version += 1
            case .removed:
                version = 1
                try! FileManager.default.removeItem(at: dataBasePath)
            }
            
            return try! initRealm()
        }
    }()
    
    func initRealm() throws -> Realm {
        let config = Realm.Configuration(schemaVersion: version)
        Realm.Configuration.defaultConfiguration = config
        let _realm = try Realm()
        return _realm
    }
    
    func addWeather(weather: WeatherJSON, source: SourceValues) {
        let weatherDB = RealmBD(weather: weather, source: source)
            do {
                try self.realm.write({
                    self.realm.add(weatherDB, update: .modified)
                })
            } catch(let error) {
                print(error.localizedDescription)
            }
    }
    
    func getWeather(source: SourceValues.RawValue) -> [(WeatherJSON, Date)] {
        return realm.objects(RealmBD.self).filter("source == %@", source).sorted(by:\.date, ascending: false).map { $0.mappedWeather() }
    }
    
    func getObserverWeather(date: Date) -> Results<RealmBD> {
        return realm.objects(RealmBD.self).filter("date == %@", date)
    }
    
    func removeWeatherFromDate(date: Date) -> [(WeatherJSON, Date)] {
        do {
            guard let removedObject = realm.objects(RealmBD.self).filter("date == %@", date).first else { return [] }
            try self.realm.write({
                self.realm.delete(removedObject)
            })
        } catch(let error) {
            print(error.localizedDescription)
        }
        return realm.objects(RealmBD.self).sorted(by:\.date, ascending: false).map { $0.mappedWeather() }
    }
    
    func removeWeatherAll() -> [(WeatherJSON, Date)] {
        do {
            let removedObject = realm.objects(RealmBD.self)
            try self.realm.write({
                self.realm.delete(removedObject)
            })
        } catch(let error) {
            print(error.localizedDescription)
        }
        return realm.objects(RealmBD.self).map { $0.mappedWeather() }
    }
}
