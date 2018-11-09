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
        if let cities = JsonUtility<City>.parseJSON(cityData) {
            tree = BinaryTree<City>.growTree(fromValues: cities)
            let name = tree?.search(searchValue: "Paris")
            let unwrappedName = name?.nodeValue?.name ?? "Empty node"
            let unwrappedLat = name?.nodeValue?.lat ?? 0
            
            print("**** city name: \(unwrappedName)")
            print("**** latitude: \(unwrappedLat)")
        }
        
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
