//
//  RootCityLabTests.swift
//  CityLabTests
//
//  Created by aarthur on 11/12/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

import XCTest
@testable import CityLab

class RootCityLabTests: XCTestCase {
    var cityArray: Array<City>!

    override func setUp() {
        super.setUp()
        
        let cityPath = Bundle.main.path(forResource: "cities", ofType: "json")
        let cityUrl = URL.init(fileURLWithPath: cityPath!)
        var cityData :Data? = nil
        
        do {
            cityData = try Data.init(contentsOf: cityUrl)
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        cityArray = JsonUtility<City>.parseJSON(cityData)
        cityArray.sort()
    }
    override func tearDown() {
        cityArray = nil
        super.tearDown()
    }

}
