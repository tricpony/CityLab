//
//  AppDelegate.swift
//  CityLab
//
//  Created by aarthur on 11/9/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let rootVC = sb.instantiateInitialViewController()
        
        self.window?.rootViewController = rootVC
        
        return true
    }

    // MARK: - Bundle Info
    
    func appDisplayName() -> String {
        let infoDictionary = Bundle.main.infoDictionary
        return infoDictionary!["CFBundleDisplayName"] as! String
    }
    
    func appID() -> String {
        let infoDictionary = Bundle.main.infoDictionary
        return infoDictionary!["CFBundleIdentifier"] as! String
    }
    
}
