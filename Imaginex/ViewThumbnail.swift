//
//  ViewThumbnail.swift
//  Imaginex
//
//  Created by Mac Mini on 10/15/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Cocoa

class ViewThumbnail: NSCollectionViewItem {

    var imageFile : NSImage? {
        didSet {
            //guard viewLoaded else { return }
            imageView?.image = imageFile
            //print("Image assigned")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        //view.layer?.backgroundColor = CGColor.black
        view.layer?.borderWidth = 0.0
        view.layer?.borderColor = CGColor.black
        //print("thumb init")
    }
    
    func setHighlight(_ selected: Bool) {
        view.layer?.borderWidth = selected ? 5.0 : 0.0
        //view.layer?.borderColor = CGColor.black
    }
    
}
