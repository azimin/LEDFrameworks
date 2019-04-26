//
//  PurchaseStatus.swift
//  LEDHelpers
//
//  Created by Alexander Zimin on 26/04/2019.
//  Copyright © 2019 led. All rights reserved.
//

import Foundation

public enum PurchaseStatus {
    case success
    case failed(error: Error?)
    case cancelled

    public var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .cancelled, .failed(_):
            return false
        }
    }
}
