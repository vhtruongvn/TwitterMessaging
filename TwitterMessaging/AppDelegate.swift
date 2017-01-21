//
//  AppDelegate.swift
//  TwitterMessaging
//
//  Created by Truong Vo on 1/20/17.
//  Copyright © 2017 Truong Vo. All rights reserved.
//

import UIKit
import Fabric
import TwitterKit
import AERecord

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Twitter & Fabric
        Twitter.sharedInstance().start(withConsumerKey: "4PYvXdUYEJqskYpyNaCYoZ45T", consumerSecret: "bQIowoxDHqlhxyhNixS5vd4ifqBnj7r1MK0stV0a6Dy0QwE3Pg")
        Fabric.with([Twitter.self()])
        
        // Core Data
        do {
            try AERecord.loadCoreDataStack()
        } catch {
            debugPrint(error)
        }
        
        // Common UI Customization
        let navBGColor = UIColor(red: 0.333, green: 0.675, blue: 0.933, alpha: 1.00)
        UINavigationBar.appearance().barTintColor = navBGColor
        UINavigationBar.appearance().backgroundColor = navBGColor
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        UIApplication.shared.statusBarStyle = .lightContent
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        // Twitter
        if Twitter.sharedInstance().application(app, open:url, options: options) {
            return true
        }
        
        // If you handle other (non Twitter Kit) URLs elsewhere in your app, return true. Otherwise
        return false
    }

}

