//
//  AppLauncher.swift
//  QuestsMaffia
//
//  Created by Alexander Zimin on 10/08/2018.
//  Copyright © 2018 questsMaffia. All rights reserved.
//

import Foundation
import LEDHelpers

final public class AppLauncher {
    public static var shared: AppLauncher!

    public enum LaunchStatus {
        case none
        case normal
        case firstTime
        case afterUpdate
    }

    public typealias ObsserverBlock = (AppLauncher) -> Void

    public var versionNumber: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }

    public class Observer {
        public var amountOfSeconds: Int
        public var block: ObsserverBlock

        public init(amountOfSeconds: Int,
                    block: @escaping ObsserverBlock) {
            self.amountOfSeconds = amountOfSeconds
            self.block = block
        }
    }

    public let launchStatus: LaunchStatus
    private var isBranchDeeplinkHandled: Bool = false
    private var isFacebookDeeplinkHandled: Bool = false

    private var timer: Timer?
    private(set) var amountOfSeconds: Int = 0

    private var observers: [Observer] = []

    public var isAllDeeplinkHandled: Bool {
        return self.isFacebookDeeplinkHandled && self.isBranchDeeplinkHandled
    }

    public init(launchStatus: LaunchStatus) {
        self.launchStatus = launchStatus
        self.startTimer()
    }

    private func startTimer() {
        self.timer = Timer(timeInterval: 1, repeats: true, block: { [weak self] (_) in
            self?.amountOfSeconds += 1
            self?.checkObservers()
        })
        RunLoop.main.add(self.timer!, forMode: RunLoop.Mode.common)
    }

    // MARK: - Public

    public func branchDeeplinkHandled() {
        self.isBranchDeeplinkHandled = true
    }

    public func facebookDeeplinkHandled() {
        self.isFacebookDeeplinkHandled = true
    }

    public func callObserverAt(amountOfSeconds: Int, status: LaunchStatus, block: @escaping ObsserverBlock) {
        if self.launchStatus == status {
            self.observers.append(Observer(amountOfSeconds: amountOfSeconds, block: block))
            self.checkObservers()
        }
    }

    // MARK: - Private

    private func checkObservers() {
        var indexesToRemove: [Int] = []
        for (index, observer) in self.observers.enumerated() {
            if observer.amountOfSeconds <= self.amountOfSeconds {
                observer.block(self)
                indexesToRemove.append(index)
            }
        }

        var offset = 0
        for index in indexesToRemove {
            self.observers.remove(at: index - offset)
            offset += 1
        }
    }

    public static func bumpVersionIfNeeded() -> AppLauncher.LaunchStatus {
        if let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            let version = UserDefaults.standard.string(forKey: ".key.version")
            var isVersionTheSame = true

            if UserDefaults.standard.string(forKey: ".key.version") != versionNumber {
                UserDefaults.standard.set(versionNumber, forKey: ".key.version")
                isVersionTheSame = false
            }

            if version == nil {
                return .firstTime
            }

            if isVersionTheSame {
                return .normal
            }

            return .afterUpdate
        } else {
            return .none
        }
    }
}
