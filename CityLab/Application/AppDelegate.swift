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
        let cityPath = Bundle.main.path(forResource: "cities", ofType: "json")
        let cityUrl = URL.init(fileURLWithPath: cityPath!)
        var cityData :Data? = nil
        var tree :BinaryTree<City>? = nil
        
        do {
            cityData = try Data.init(contentsOf: cityUrl)
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        let cityPlist = JsonUtility.parseJSON(cityData)
        tree = BinaryTree<City>.growTree(fromJson: cityPlist!)
        let name = tree?.search(searchValue: "Paris")
        let unwrappedName = name?.nodeValue ?? "Empty node"
        
        print("**** city name: \(unwrappedName)")
        
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
