//
//  GameService.swift
//  BloggerApp
//
//  Created by Alexander Zimin on 25/05/2018.
//  Copyright © 2018 alex. All rights reserved.
//

import Foundation
import LEDHelpers

public class TimerService {
    public init() { }

    public var isTimerActive: Bool {
        return self.timerEndDate != nil
    }

    public var timerEndDate: Date? {
        set {
            ServiceLocator.shared.timeTravelDataSource.timerEndDate = newValue
            self.callObservers(date: newValue)
        }
        get {
            guard ServiceLocator.shared.timeTravelDataSource.shouldReturnTimerDate else {
                return nil
            }
            return ServiceLocator.shared.timeTravelDataSource.timerEndDate
        }
    }

    public func resetTimer() {
        self.timerEndDate = nil
    }

    public enum BlockerStatus {
        case noTime
        case timeNotEnded
        case approximateTimeEnded
        case internetTimeEnded
        case noInternetConnection
        case errorOnTimeTravelSide
        case internetDateNotFit(date: Date)
    }

    public func checkBlockerStatus(completion: @escaping (BlockerStatus) -> Void) {
        guard let targetDate = self.timerEndDate else {
            completion(.noTime)
            return
        }

        if !self.ifCurrentTimeFit(time: Date(), targetDate: targetDate, accuracy: .perfect) {
            completion(.timeNotEnded)
            return
        }

        if let lastTime = TimeTravelService.shared.lastLoadedDate {
            if self.ifCurrentTimeFit(time: lastTime, targetDate: targetDate, accuracy: .approximate) {
                completion(.approximateTimeEnded)
                return
            }
        }

        TimeTravelService.shared.travel { (result) in
            switch result {
            case let .date(date: date):
                if self.ifCurrentTimeFit(time: date, targetDate: targetDate, accuracy: .perfect) {
                    completion(.internetTimeEnded)
                    return
                } else {
                    completion(.internetDateNotFit(date: date))
                    return
                }
            case .error:
                completion(.errorOnTimeTravelSide)
                return
            case .noInternet:
                completion(.noInternetConnection)
                return
            }
        }
    }

    private enum Accuracy {
        case perfect
        case approximate
    }

    private func ifCurrentTimeFit(time: Date, targetDate: Date, accuracy: Accuracy) -> Bool {
        switch accuracy {
        case .perfect:
            return time.timeIntervalSince(targetDate) >= -10
        case .approximate:
            return time.timeIntervalSince(targetDate) >= -60 * 60
        }
    }

    // MARK: - Observers

    public typealias ObserverBlock = (_ date: Date?) -> Void

    private var observers: [Observer<ObserverBlock>] = []

    public func addObserver(object: AnyObject, block: @escaping ObserverBlock) {
        let observer = Observer(object: object, block: block)
        self.observers.append(observer)
    }

    private func callObservers(date: Date?) {
        while let index = self.observers.firstIndex(where: { $0.object == nil }) {
            self.observers.remove(at: index)
        }

        for observer in self.observers {
            observer.block?(date)
        }
    }
}
