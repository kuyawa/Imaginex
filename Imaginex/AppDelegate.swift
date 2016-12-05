//
//  AppDelegate.swift
//  Imaginex
//
//  Created by Mac Mini on 10/12/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("Hello!")
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    // Add this handler to all apps, close on red button click
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        print("Goodbye!")
        return true
    }

}

