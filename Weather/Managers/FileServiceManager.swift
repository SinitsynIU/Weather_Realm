//
//  FileServiceManager.swift
//  Weather
//
//  Created by Илья Синицын on 23.03.2022.
//

import UIKit

class FileServiceManager {
    static let shared = FileServiceManager()
    
    let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
       
    fileprivate func directoryExistsAtPath(_ path: String) -> Bool {
        var isDirectory = ObjCBool(true)
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }
    
    func getWeatherImage(icon: String, completed: @escaping (UIImage?) -> ()) {
        guard let url = APIWeather.icon.getIconURL(icon: icon) else { return }
        let imageURL = documentDirectory.appendingPathComponent(url.absoluteString)
        if !directoryExistsAtPath(imageURL.deletingLastPathComponent().path) {
            do {
                try FileManager.default.createDirectory(atPath: imageURL.deletingLastPathComponent().path, withIntermediateDirectories: true, attributes: nil)
            } catch (let e) {
                print(e.localizedDescription)
            }
        }
        guard let dataImage = FileManager.default.contents(atPath: imageURL.path) else {
            DispatchQueue.global().async {
                guard let url = URL(string: url.absoluteString) else { return }
                if let dataImage = try? Data(contentsOf: url) {
                    do {
                        try dataImage.write(to: imageURL)
                        DispatchQueue.main.async {
                            completed(UIImage(data: dataImage))
                        }
                    } catch (let e) {
                        print(e.localizedDescription)
                    }
                }
            }
            return
        }
        completed(UIImage(data: dataImage))
      }
    
    func getNewsImage(imageUrl: String?, completed: @escaping (UIImage?) -> ()) {
        guard let url = imageUrl else { return }
        print(url)
        let imageURL = documentDirectory.appendingPathComponent(url)
        if !directoryExistsAtPath(imageURL.deletingLastPathComponent().path) {
            do {
                try FileManager.default.createDirectory(atPath: imageURL.deletingLastPathComponent().path, withIntermediateDirectories: true, attributes: nil)
            } catch (let e) {
                print(e.localizedDescription)
            }
        }
        guard let dataImage = FileManager.default.contents(atPath: imageURL.path) else {
            DispatchQueue.global().async {
                guard let url = URL(string: url) else { return }
                if let dataImage = try? Data(contentsOf: url) {
                    do {
                        try dataImage.write(to: imageURL)
                        DispatchQueue.main.async {
                            completed(UIImage(data: dataImage))
                        }
                    } catch (let e) {
                        print(e.localizedDescription)
                    }
                }
            }
            return
        }
        completed(UIImage(data: dataImage))
      }
}
