//
//  AppDelegate.swift
//  TrainGetter
//
//  Created by Renato Ioshida on 16/09/17.
//  Copyright © 2017 Renato Ioshida. All rights reserved.
//

import Cocoa
import FirebaseCore
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        FirebaseApp.configure()
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

