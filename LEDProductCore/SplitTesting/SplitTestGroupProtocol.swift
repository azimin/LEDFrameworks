//
//  SplitTestGroupType.swift
//  SplitTests
//
//  Created by Alex Zimin on 15/06/2018.
//  Copyright © 2018 Akexander. All rights reserved.
//

import Foundation
import CoreGraphics

public protocol SplitTestGroupProtocol: RawRepresentable where RawValue == String {
    var probability: CGFloat? { get }
    static var testGroups: [Self] { get }
}
