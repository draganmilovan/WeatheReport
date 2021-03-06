//
//  AppDelegate.swift
//  WeatheReport
//
//  Created by Dragan Milovanovic on 10/19/17.
//  Copyright © 2017 Dragan Milovanovic. All rights reserved.
//

import UIKit
import RTCoreDataStack

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var coreDataStack: RTCoreDataStack?
    var dataManager: WeatherDataManager?
    var locationsManager: LocationsManager?
    
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        coreDataStack = RTCoreDataStack {
            [unowned self] in
            
            self.configureDataManagers()
            
            let dependency = Dependency(dataManager: self.dataManager, locationsManager: self.locationsManager)
            
            if let cvc = self.window?.rootViewController as? WRCollectionViewController {
                cvc.dependency = dependency
            }
            
            if let tvc = self.window?.rootViewController as? LocationsTableViewController {
                tvc.dependency = dependency
            }
        }
        
        return true
    }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
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
    }


}


extension AppDelegate {
    
    func configureDataManagers() {
        
        guard let cds = coreDataStack else { fatalError() }
        dataManager = WeatherDataManager(coreDataStack: cds)
        locationsManager = LocationsManager()
    }
    
}
