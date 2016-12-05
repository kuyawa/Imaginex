//
//  Spinner.swift
//  Imaginex
//
//  Created by Mac Mini on 10/20/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Cocoa
import Foundation

class Spinner {
    var X       :Int = 100
    var Y       :Int = 100
    var width   :Int = 32
    var height  :Int = 32
    var view    :NSView
    var control :NSProgressIndicator
    
    init(with view: NSView) {
        self.view = view
        self.control = NSProgressIndicator()
        control.isIndeterminate = true
        control.style = NSProgressIndicatorStyle.spinningStyle
    }
    
    func show(){
        control.frame = NSRect(x: self.X, y: self.Y, width: self.width, height: self.height)
        view.addSubview(control)
    }
    
    func hide() {
        view.willRemoveSubview(control)
    }
}
