//
//  ProductCore.swift
//  ProductCore
//
//  Created by Alexander Zimin on 22/09/2018.
//  Copyright © 2018 questsMaffia. All rights reserved.
//

import Foundation
import LEDCore

public class ProductCore {
    private static var isSet = false

    public static func setup(assertionHandler: AssertionHandler) {
        if self.isSet {
            appAssertionFailure("ProductCore already set")
        } else {
            self.isSet = true
        }

    }
}
