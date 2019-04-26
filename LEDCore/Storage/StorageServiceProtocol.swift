//
//  StorageServiceProtocol.swift
//  SplitTests
//
//  Created by Alex Zimin on 15/06/2018.
//  Copyright © 2018 Akexander. All rights reserved.
//

import Foundation

public protocol StorageServiceProtocol {
    func save(object: String?, for key: String)
    func getObject(for key: String) -> String?

    func save(object: Int?, for key: String)
    func getObject(for key: String) -> Int?

    func save(object: Bool?, for key: String)
    func getObject(for key: String) -> Bool?

    func save(object: NSObject?, for key: String)
    func getObject(for key: String) -> NSObject?
}

public extension StorageServiceProtocol {
    func bool(for key: String) -> Bool {
        return (self.getObject(for: key) as Bool?) ?? false
    }

    func int(for key: String) -> Int {
        return (self.getObject(for: key) as Int?) ?? 0
    }

    func string(for key: String) -> String {
        return (self.getObject(for: key) as String?) ?? ""
    }
}
