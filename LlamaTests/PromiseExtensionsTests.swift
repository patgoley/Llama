//
//  PromiseExtensionsTests.swift
//  Llama
//
//  Created by Patrick Goley on 10/8/16.
//  Copyright © 2016 patrickgoley. All rights reserved.
//

import XCTest
@testable import Llama

class PromiseOperationsTests: XCTestCase {

    func testPromiseAll() {
        
        let promise = Promise.all(resolveImmediately(10), resolveAsync(100))
        
        let expt = expectation(description: "promise all")
        
        promise.nextHandler = { value in
            
            XCTAssert(value == [10, 100])
            
            expt.fulfill()
        }
        
        waitForExpectations(timeout: 0.2, handler: nil)
    }
    
    func testPromiseAllWithRejection() {
        
        let promise = Promise.all(resolveAsync(10), resolveAsync(100), rejectImmediately())
        
        let expt = expectation(description: "promise all rejection")
        
        promise.errorHandler = { err in
            
            expt.fulfill()
        }
        
        waitForExpectations(timeout: 0.2, handler: nil)
    }
}
