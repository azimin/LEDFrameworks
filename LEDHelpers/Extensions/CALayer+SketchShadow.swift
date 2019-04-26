//
//  CALayer+SketchShadow.swift
//  LEDHelpers
//
//  Created by Alexander Zimin on 26/04/2019.
//  Copyright © 2019 led. All rights reserved.
//

import Foundation

extension CALayer {
    public func applySketchShadow(
        color: UIColor,
        alpha: CGFloat,
        x: CGFloat,
        y: CGFloat,
        blur: CGFloat,
        spread: CGFloat,
        pathProvider: ((_ inset: CGFloat) -> UIBezierPath)?)
    {
        self.shadowColor = color.cgColor
        self.shadowOpacity = Float(alpha)
        self.shadowOffset = CGSize(width: x, height: y)
        self.shadowRadius = blur / 2.0
        if let pathProvider = pathProvider {
            let path = pathProvider(-spread)
            self.shadowPath = path.cgPath
        } else if spread == 0 {
            self.shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            self.shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
}
