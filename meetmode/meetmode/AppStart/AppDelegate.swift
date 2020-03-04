//
//  AppDelegate.swift
//  meetmode
//
//  Created by Varun Iyer on 3/2/20.
//  Copyright © 2020 spott. All rights reserved.
//

import UIKit
import RIBs
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var launchRouter: LaunchRouting?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        let launchViewController = LaunchViewController(w: window.frame.width, h: window.frame.height)
        self.window?.rootViewController = launchViewController
        self.window?.makeKeyAndVisible()
        
        if CLLocationManager.authorizationStatus() != .notDetermined {
            launchRouter = RootBuilder(dependency: AppComponent()).build(loggedIn: true)
            launchRouter?.launchFromWindow(window)
        } else {
            launchRouter = RootBuilder(dependency: AppComponent()).build(loggedIn: false)
            launchRouter?.launchFromWindow(window)
        }
        
        return true
    }
}

