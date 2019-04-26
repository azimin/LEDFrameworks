//
//  PurchaseHandlerProtocol.swift
//  PurchaseCore
//
//  Created by Alexander Zimin on 23/09/2018.
//  Copyright © 2018 questsMaffia. All rights reserved.
//

import Foundation

public protocol PurchaseHandlerProtocol {
    associatedtype Product: ProductProtocol
    func newPurchaseHandled(type: PurchaseType, product: Product)
}
