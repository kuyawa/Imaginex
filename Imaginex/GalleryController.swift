//
//  GalleryController.swift
//  Imaginex
//
//  Created by Mac Mini on 10/23/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Foundation
import Cocoa

class GalleryController: NSViewController {
    
    enum responseType {
        case saved, cancelled
    }
    
    var gallery  :Gallery      = Gallery()
    var settings :Settings     = Settings()
    var response :responseType = .cancelled

    @IBOutlet weak var textName: NSTextField!
    @IBOutlet weak var textURL : NSTextField!
    
    @IBAction func buttonAddGallery(_ sender: NSButton) {
        addGallery()
    }
    
    @IBAction func buttonCancel(_ sender: NSButton) {
        cancelEvent()
    }


    //-- View delegates
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settings.load()
    }

    override func viewDidAppear() {
        if let window = self.view.window {
            window.delegate = self
            window.styleMask.remove(.resizable)      // Non resizeable
            window.styleMask.remove(.fullScreen)     // Non maximizeable
            window.styleMask.remove(.miniaturizable) // Non minimizeable
        }
    }

    override func viewWillDisappear() {
        // Return values to caller?
    }

    
    //-- User events
    
    func addGallery() {

        // get data from fields
        let name = textName.stringValue
        let url  = textURL.stringValue
        
        // validate fields
        if name.isEmpty {
            AlertOK("Gallery name can not be empty").show()
            return
        }
        
        if url.isEmpty {
            AlertOK("Gallery URL can not be empty").show()
            return
        }

        // add gallery to settings
        gallery.name    = name
        gallery.url     = url
        gallery.image   = "nopic.jpg"
        let ok = settings.addGallery(gallery)  // and save
        if ok {
            self.response = .saved
            windowRelease()
        } else {
            print("Gallery can not be saved. Try again")
            cancelEvent()
        }
    }
    
    func cancelEvent() {
        self.response = .cancelled
        windowRelease()
    }

    func windowRelease() {
        self.view.window?.close()
    }
    //-- End user events
}


extension GalleryController : NSWindowDelegate {
    func windowShouldClose(_ sender: Any) -> Bool {
        // This method is called form the red button in the window bar
        // Return false to avoid closing it
        return true
    }

    func windowWillClose(_ notification: Notification) {
        // This method is called from anywhere after the window is closed
        let app = NSApplication.shared()
        app.stopModal()
    }
}

//-- END
