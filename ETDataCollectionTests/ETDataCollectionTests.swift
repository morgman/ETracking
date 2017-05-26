//
//  ETDataCollectionTests.swift
//  ETDataCollectionTests
//
//  Created by Jones, Morgan on 5/19/17.
//  Copyright © 2017 Jones, Morgan. All rights reserved.
//

import XCTest
@testable import ETDataCollection

class ETDataCollectionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testStoryboardConstructorShallCreateAnInstance() {
        // ~given
        var sb:UIStoryboard? = nil
        
        // ~when
        sb = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // ~then
        XCTAssertNotNil(sb, "Unable to instantiate Main Storyboard")
    }
    
    func testViewControllerConstructorShallCreateAnInstance() {
        let sb = UIStoryboard(name: "Main", bundle: Bundle.main)

        // ~given
        var vc:UIViewController? = nil
        
        // ~when
        vc = sb.instantiateViewController(withIdentifier: "ViewController")
        
        // ~then
        XCTAssertNotNil(vc, "Unable to instantiate ViewController")
    }

    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
