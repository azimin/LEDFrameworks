//
//  UserDefaults+Storage.swift
//  SplitTests
//
//  Created by Alex Zimin on 15/06/2018.
//  Copyright © 2018 Akexander. All rights reserved.
//

import Foundation

extension UserDefaults: StorageServiceProtocol {
    public func save(object: NSObject?, for key: String) {
        self.setValue(object, forKey: key)
        self.synchronize()
    }

    public func getObject(for key: String) -> NSObject? {
        return self.object(forKey: key) as? NSObject
    }

    public func save(object: String?, for key: String) {
        self.set(object, forKey: key)
        self.synchronize()
    }

    public func getObject(for key: String) -> String? {
        return self.object(forKey: key) as? String
    }

    public func save(object: Int?, for key: String) {
        self.set(object, forKey: key)
        self.synchronize()
    }

    public func getObject(for key: String) -> Int? {
        return self.object(forKey: key) as? Int
    }

    public func save(object: Bool?, for key: String) {
        self.set(object, forKey: key)
        self.synchronize()
    }

    public func getObject(for key: String) -> Bool? {
        return self.object(forKey: key) as? Bool
    }
}
