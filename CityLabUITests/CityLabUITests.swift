//
//  CityLabUITests.swift
//  CityLabUITests
//
//  Created by aarthur on 11/12/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

import XCTest

class CityLabUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()

        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    func delayFor(expectation: XCTestExpectation, maxSeconds: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + maxSeconds) {
            expectation.fulfill()
        }
        
        self.wait(for: [expectation], timeout: maxSeconds * 2.0)
    }
    
    func testSearchPerformance() {
        let delay = expectation(description: "Waiting for cities to load...")
        
        self.delayFor(expectation: delay, maxSeconds: 10.0)
        let searchBar = app.otherElements["Search City"]
//        let searchBar = app.navigationBars.element(boundBy: 0).searchFields["Search City"]
//        let navBar = app.navigationBars.element(boundBy: 0)
//        let searchBar = navBar.searchFields.element(boundBy: 0)
//        let searchBar = app.navigationBars.element(boundBy: 0).searchFields.element(boundBy: 0)
        searchBar.tap()
        searchBar.typeText("Chicago")
        XCTAssert(false, "NA")
    }

}
