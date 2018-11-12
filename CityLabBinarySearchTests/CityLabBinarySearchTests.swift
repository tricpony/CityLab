//
//  CityLabBinarySearchTests.swift
//  CityLabBinarySearchTests
//
//  Created by aarthur on 11/12/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

import XCTest

class CityLabBinarySearchTests: RootCityLabTests {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testBinaryPrefixSearchPass() {
        let safeIndex = cityArray.binaryPrefixSearch(searchTerm: "Paris")
        XCTAssertNotEqual(safeIndex, nil, "Search should not return nil")
    }
    
    func testBinaryPrefixSearchFail() {
        let safeIndex = cityArray.binaryPrefixSearch(searchTerm: "Cambodia")
        XCTAssertEqual(safeIndex, nil, "Search should return nil")
    }
    
    func testBinaryPrefixSearchOutOfRange() {
        var trailFloatingIndex = cityArray.binaryPrefixSearchOutOfRange(searchTerm: "Chi")
        XCTAssertFalse(trailFloatingIndex > cityArray.count-1, "Should always return Int equal to or less than upper bounding index")
        
        trailFloatingIndex = cityArray.binaryPrefixSearchOutOfRange(searchTerm: "Chic")
        XCTAssertFalse(trailFloatingIndex > cityArray.count-1, "Should always return Int equal to or less than upper bounding index")
        
        trailFloatingIndex = cityArray.binaryPrefixSearchOutOfRange(searchTerm: "Chica")
        XCTAssertFalse(trailFloatingIndex > cityArray.count-1, "Should always return Int equal to or less than upper bounding index")
    }

}
