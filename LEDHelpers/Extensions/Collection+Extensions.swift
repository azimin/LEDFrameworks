//
//  Collection+Extensions.swift
//  LEDHelpers
//
//  Created by Alexander Zimin on 26/04/2019.
//  Copyright © 2019 led. All rights reserved.
//

import Foundation

public extension Dictionary {
    func byAppending(collection: [Key: Value]) -> [Key: Value] {
        var mutable = self
        for (key, value) in collection {
            mutable[key] = value
        }
        return mutable
    }
}
