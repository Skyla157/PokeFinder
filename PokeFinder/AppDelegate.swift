//
//  AppDelegate.swift
//  PokeFinder
//
//  Created by Meagan McDonald on 8/17/16.
//  Copyright © 2016 Skyla Apps. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
        FIRApp.configure()
        return true
    }
}

