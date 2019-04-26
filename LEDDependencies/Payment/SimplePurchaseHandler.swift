//
//  SimplePurchaseHandler.swift
//  LEDDependencies
//
//  Created by Alexander Zimin on 27/04/2019.
//  Copyright © 2019 led. All rights reserved.
//

import Foundation
import LEDPayment

public class SimplePurchaseHandler<PurchaseProduct: ProductProtocol>: PurchaseHandlerProtocol {
    public typealias Product = PurchaseProduct

    public func newPurchaseHandled(type: PurchaseType, product: Product) {
        switch type {
        case .product:
            break
        case .subscription:
            break
        }
    }
}
