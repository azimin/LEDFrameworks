//
//  Observer.swift
//  QuestsMaffia
//
//  Created by Alexander Zimin on 16/08/2018.
//  Copyright © 2018 questsMaffia. All rights reserved.
//

import Foundation

public class Observer<BlockValue> {
    public weak var object: AnyObject?
    public var block: BlockValue?

    public init(object: AnyObject,
                block: BlockValue?) {
        self.object = object
        self.block = block
    }
}
