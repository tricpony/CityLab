//
//  CityLabTests.swift
//  CityLabTests
//
//  Created by aarthur on 11/9/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

import XCTest
@testable import CityLab

class CityLabTests: RootCityLabTests {
    var controllerUnderTest: SearchViewController!
    
    override func setUp() {
        super.setUp()
        
        let searchSB = UIStoryboard(name: "Search", bundle: nil)
        let searchNavVC = searchSB.instantiateViewController(withIdentifier: "Search") as? SearchViewController
        
        controllerUnderTest = searchNavVC
        controllerUnderTest.dataSource = self.cityArray
        controllerUnderTest.isNarrowingSearch = true
    }

    override func tearDown() {
        controllerUnderTest = nil
        super.tearDown()
    }

    func testSUT_canBeInstantiated() {
        XCTAssertNotNil(controllerUnderTest, "Search view controller is missing")
    }
    
    func testSUT_hasSearchBar() {
        XCTAssertNotNil(controllerUnderTest.searchController.searchBar, "Search controller has no search bar")
    }
    
    /*
        Test that search results count equals correct amount
    */
    func testSUT_canPerformPrefixSearchPass() {
        controllerUnderTest.processSearchResults(searchTerm: "New O")
        XCTAssertEqual(controllerUnderTest.dataSource.count, 2, "Search results count should be 2")
        
        controllerUnderTest.processSearchResults(searchTerm: "New Or")
        XCTAssertEqual(controllerUnderTest.dataSource.count, 1, "Search results count should be 1")
    }
    
    /*
     Test that search results count does not equal zero
     */
    func testSUT_canPerformPrefixSearchFail() {
        controllerUnderTest.processSearchResults(searchTerm: "New O")
        XCTAssertNotEqual(controllerUnderTest.dataSource.count, 0, "Search results count should not be 0")
        
        controllerUnderTest.processSearchResults(searchTerm: "New Or")
        XCTAssertNotEqual(controllerUnderTest.dataSource.count, 0, "Search results count should not be 0")
    }
    
    /*
     Test that search results count is not greater than zero when there is no match
     */
    func testSUT_canPerformPrefixSearchIsZero() {
        controllerUnderTest.processSearchResults(searchTerm: "Cambodia")
        
        let exp = controllerUnderTest.dataSource.count > 0
        XCTAssertTrue(exp == false, "Search results count should not be greater than 0")
    }
    
    func testPerformanceSearchAddOnly() {

        self.measure {
            controllerUnderTest.processSearchResults(searchTerm: "Chi")
            controllerUnderTest.processSearchResults(searchTerm: "Chic")
            controllerUnderTest.processSearchResults(searchTerm: "Chica")
            controllerUnderTest.processSearchResults(searchTerm: "Chicago")
        }
    }
    
    func testPerformanceSearchAddDelete() {
        controllerUnderTest.masterDataSource = cityArray
        self.measure {
            controllerUnderTest.processSearchResults(searchTerm: "Chi")
            controllerUnderTest.processSearchResults(searchTerm: "Chic")
            controllerUnderTest.isNarrowingSearch = false
            controllerUnderTest.processSearchResults(searchTerm: "Chi")
            controllerUnderTest.isNarrowingSearch = true
            controllerUnderTest.processSearchResults(searchTerm: "Chica")
            controllerUnderTest.processSearchResults(searchTerm: "Chicago")
        }
    }

}
