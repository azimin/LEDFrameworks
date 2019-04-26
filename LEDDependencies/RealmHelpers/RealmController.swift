//
//  RealmController.swift
//
//  Created by Igor Tudoran on 07.02.17.
//

import Foundation
import RealmSwift
import LEDCore

public class RealmController {
    public var mainRealm: Realm?
    public static var shared: RealmController = RealmController()

    public static func setup(schemaVersion: UInt64, migrationBlock: @escaping MigrationBlock) {
        shared.setup(schemaVersion: schemaVersion, migrationBlock: migrationBlock)
    }

    private func setup(schemaVersion: UInt64, migrationBlock: @escaping MigrationBlock) {
        let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask,
                                                             appropriateFor: nil, create: false)
        let url = documentDirectory.appendingPathComponent("helpers_main_realm.realm")
        let configuration: Realm.Configuration = Realm.Configuration(fileURL: url,
                                                                     schemaVersion: schemaVersion,
                                                                     migrationBlock: migrationBlock)
        do {
            self.mainRealm = try Realm(configuration: configuration)
        } catch let error as NSError {
            NotificationCenter.default.post(name: .RealmLoadingErrorNotifications,
                                            object: nil)
            appAssertionFailure("Realm loading error: \(error)")
        }
    }
}
