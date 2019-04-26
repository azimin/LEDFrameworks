//
//  SimpleKeychain+Storage.swift
//  The Front Page
//
//  Created by Alexander Zimin on 19/06/2018.
//  Copyright © 2018 Egor Kuznetsov. All rights reserved.
//

import Foundation
import SimpleKeychain

extension A0SimpleKeychain: StorageServiceProtocol {
    public func save(object: NSObject?, for key: String) {
        if let object = object {
            if let value = object as? String {
                self.save(object: value, for: key)
            } else if let value = object as? Int {
                self.save(object: value, for: key)
            } else if let value = object as? Bool {
                self.save(object: value, for: key)
            } else {
                appAssertionFailure("No supported type")
            }
        } else {
            self.deleteEntry(forKey: key)
        }
    }

    public func getObject(for key: String) -> NSObject? {
        if self.hasValue(forKey: key) {
            if let value = self.getObject(for: key) as Int? {
                return value as NSObject
            } else if let value = self.getObject(for: key) as String? {
                return value as NSObject
            } else if let value = self.getObject(for: key) as Bool? {
                return value as NSObject
            } else {
                appAssertionFailure("No supported")
            }
        }
        return nil
    }

    public func save(object: String?, for key: String) {
        if let object = object {
            self.setString(object, forKey: key)
        } else {
            self.deleteEntry(forKey: key)
        }
    }

    public func getObject(for key: String) -> String? {
        return self.string(forKey: key)
    }

    public func save(object: Int?, for key: String) {
        if let object = object {
            self.setString("\(object)", forKey: key)
        } else {
            self.deleteEntry(forKey: key)
        }
    }

    public func getObject(for key: String) -> Int? {
        if let value = self.string(forKey: key),
            let number = Int(value) {
            return number
        }
        return nil
    }

    public func save(object: Bool?, for key: String) {
        if let object = object {
            self.setString("\(object)", forKey: key)
        } else {
            self.deleteEntry(forKey: key)
        }
    }

    public func getObject(for key: String) -> Bool? {
        if let value = self.string(forKey: key),
            let bool = Bool(value) {
            return bool
        }
        return nil
    }
}
