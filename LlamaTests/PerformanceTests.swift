//
//  PerformanceTests.swift
//  Llama
//
//  Created by Patrick Goley on 10/9/16.
//  Copyright © 2016 patrickgoley. All rights reserved.
//

import XCTest
@testable import Llama

class PerformanceTests: XCTestCase {
    
    
    
    func testPerformanceExample() {
        
        var newState: State<Int>! = nil
        
        self.measure {
            
            let promise = Promise<Int>()
            
            var _ = promise.state
            
            promise.resolve(11)
            
            newState = promise.state
        }
        
        print(newState)
    }
    
}
