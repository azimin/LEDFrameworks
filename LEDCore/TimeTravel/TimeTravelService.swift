//
//  TimeTravelService.swift
//  TimeTravel
//
//  Created by Alexander Zimin on 03/06/2018.
//  Copyright © 2018 alex. All rights reserved.
//

import Foundation
import LEDHelpers

public class TimeTravelService {
    public typealias ObserverBlock = () -> Void

    private var cachedValue: Date?
    private var cachedInternetValue: Date?

    public enum Result {
        case date(date: Date)
        case error
        case noInternet
    }

    public func resetCache() {
        self.cachedValue = nil
        self.cachedInternetValue = nil
    }

    public static var shared: TimeTravelService = TimeTravelService()

    public var lastLoadedDate: Date? {
        set {
            ServiceLocator.shared.timeTravelDataSource.lastLoadedDate = newValue
        }
        get {
            return ServiceLocator.shared.timeTravelDataSource.lastLoadedDate
        }
    }

    // MARK: - Observers

    private var observers: [Observer<ObserverBlock>] = []

    public func addObserver(object: AnyObject, block: @escaping ObserverBlock) {
        let observer = Observer(object: object, block: block)
        self.observers.append(observer)
    }

    private func callObservers() {
        while let index = self.observers.firstIndex(where: { $0.object == nil }) {
            self.observers.remove(at: index)
        }

        for observer in self.observers {
            observer.block?()
        }
    }

    // MARK: - Travel

    public func travel(completion: ((Result) -> Void)? = nil) {
        if let cachedValue = self.cachedValue,
            let cachedInternetValue = self.cachedInternetValue {
            let timeInterval = Date().timeIntervalSince(cachedValue)
            let date = cachedInternetValue.addingTimeInterval(timeInterval)
            completion?(.date(date: date))
            return
        }

        guard Reachability.isConnectedToNetwork else {
            completion?(.noInternet)
            return
        }

        let url = URL(string: "https://script.google.com/macros/s/AKfycbyd5AcbAnWi2Yn0xhFRbyzS4qMq1VucMVgVvhul5XqS9HkAyJY/exec")!
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            OperationQueue.main.addOperation {
                guard let data = data, error == nil else {
                    if let nsError = error as NSError? {
                        if nsError.code == -1009 || nsError.code == -1001 {
                            completion?(.noInternet)
                            return
                        }
                    }
                    completion?(.error)
                    return
                }

                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    completion?(.error)
                    return
                }

                let json = try? JSONSerialization.jsonObject(with: data, options: [])

                guard let jsonDic = json as? [String: Any] else {
                    completion?(.error)
                    return
                }

                guard let day = jsonDic["day"] as? Int,
                    let month = jsonDic["month"] as? Int,
                    let year = jsonDic["year"] as? Int,
                    let hours = jsonDic["hours"] as? Int,
                    let minutes = jsonDic["minutes"] as? Int,
                    let seconds = jsonDic["seconds"] as? Int else {
                        completion?(.error)
                        return
                }

                let formatter = DateFormatter()
                formatter.timeZone = TimeZone(abbreviation: "UTC")
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                if let date = formatter.date(from: "\(year)-\(month)-\(day) \(hours):\(minutes):\(seconds)") {
                    TimeTravelService.shared.lastLoadedDate = date
                    self.cachedInternetValue = date
                    self.cachedValue = Date()
                    self.callObservers()
                    completion?(.date(date: date))
                } else {
                    completion?(.error)
                }
            }
        }
        task.resume()
    }
}
