//
//  CoreDataManager.swift
//  Weather
//
//  Created by Илья Синицын on 14.04.2022.
//

import CoreData

enum SourceValues: String {
    case city
    case coordinate
}

class CoreDataManager {
    static let shared = CoreDataManager()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "WeatherDataBase")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func addWeather(weather: WeatherJSON, source: SourceValues) {
        let weatherDB =  WeatherDB(context: context)
        weatherDB.setValues(weather: weather, source: source)
        self.context.insert(weatherDB)
        saveContext()
    }
    
    func getWeatherSourceFromDB(source: SourceValues.RawValue) -> [(WeatherJSON, Date)] {
        // -> WeatherDB? {
       let request = WeatherDB.fetchRequest(source: source)
        //return try? self.context.fetch(request).first
        let sort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sort]
        guard let paremeters = try? context.fetch(request) else { return [] }
        return paremeters.map { $0.getMappedWeather() }
    }
    
//    func getAllWeatherFromDB() -> [WeatherJSON] {
//       let request = WeatherDB.fetchRequest()
//        guard let paremeters = try? context.fetch(request) else { return [] }
//        return paremeters.map { $0.getMappedWeather() }
//    }
    
    func saveContext () {
        let context = context
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func deleteWeather(date: Date) {
        let request = WeatherDB.fetchRequest(date: date)
        guard let object = try? context.fetch(request).first else { return }
        context.delete(object)
        NotificationCenter.default.post(name: NSNotification.Name("WeatherDataBaseDidChange"), object: nil)
        saveContext()
    }
    
    func deleteWeatherAll() {
        let request = WeatherDB.fetchRequest()
        do {
            let weatherDB = try self.context.fetch(request)
            weatherDB.forEach {
                self.context.delete($0)
            }
            self.saveContext()
        } catch (let e) {
            print(e.localizedDescription)
        }
    }
}
