//
//  ETDataObserverTests.swift
//  ETDataCollection
//
//  Created by Jones, Morgan on 5/26/17.
//  Copyright © 2017 Jones, Morgan. All rights reserved.
//

import Foundation

import XCTest
@testable import ETDataCollection

class ETDataObserverTests: XCTestCase {
    
    func testConstuctorShallCreateInstance() {

        // ~given
        var vc:observerAdderClass? = nil
        
        // ~when
        vc = observerAdderClass.init()
        
        // ~then
        XCTAssertNotNil(vc, "Unable to instantiate observerAdderClass")
    }

}
