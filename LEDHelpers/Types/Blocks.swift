//
//  Blocks.swift
//  LEDHelpers
//
//  Created by Alexander Zimin on 26/04/2019.
//  Copyright © 2019 led. All rights reserved.
//

import Foundation

public typealias VoidBlock = () -> Void
public typealias CompletionBlock = (_ success: Bool) -> Void
public typealias PurchaseBlock = (_ result: PurchaseStatus) -> Void
