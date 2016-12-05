//
//  ColorUtils.swift
//  Imaginex
//
//  Created by Mac Mini on 12/5/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Cocoa
import Foundation

// let red = NSColor(hex:0xff0000)
extension NSColor {
    convenience init(hex: Int) {
        var opacity : CGFloat = 1.0
        
        if hex > 0xffffff {
            opacity = CGFloat((hex >> 24) & 0xff) / 255
        }
        
        let parts = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255,
            A: opacity
        )
        
        self.init(red: parts.R, green: parts.G, blue: parts.B, alpha: parts.A)
    }
}

