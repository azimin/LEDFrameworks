//
//  ProductProtocol.swift
//  PurchaseCore
//
//  Created by Alexander Zimin on 23/09/2018.
//  Copyright © 2018 questsMaffia. All rights reserved.
//

import Foundation

public protocol ProductProtocol: Hashable {
    var identifier: String { get }
    var analyticsName: String { get }
    var purchaseType: PurchaseType { get }
    var isTrial: Bool { get }
    var price: CGFloat { get }
    init?(identifier: String)
    static var allProducts: [Self] { get }
}

public enum PurchaseType {
    case subscription
    case product
}
