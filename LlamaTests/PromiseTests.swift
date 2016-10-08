//
//  PromiseTests.swift
//  Llama
//
//  Created by Patrick Goley on 10/8/16.
//  Copyright © 2016 patrickgoley. All rights reserved.
//

import Foundation
import XCTest
@testable import Llama

class PromiseTests: XCTestCase {
    
    func testResolution() {
        
        let expt = expectation(description: "resolve")
        
        let promise = resolveAsync(5)
        
        promise.nextHandler = { value in
         
            XCTAssert(value == 5)
            
            expt.fulfill()
        }
        
        waitForExpectations(timeout: 0.2, handler: nil)
    }
    
    func testRejection() {
        
        let expt = expectation(description: "resolve")
        
        let promise = rejectAsync()
        
        promise.errorHandler = { err in
            
            switch err {
                
            case TestError.Default: break
            default: XCTFail()
            }
            
            expt.fulfill()
        }
        
        waitForExpectations(timeout: 0.2, handler: nil)
    }
    
    func testResolvesExactlyOnce() {
        
        let workExpt = expectation(description: "resolve")
        
        var workCount = 0
        
        let promise = Promise<Int>() { resolve, reject in
            
            resolve(5)
            
            workCount += 1
            
            XCTAssert(workCount == 1)
            
            workExpt.fulfill()
        }
        
        let firstExpt = expectation(description: "first handler")
        
        promise.nextHandler = { value in
            
            XCTAssert(value == 5)
            
            firstExpt.fulfill()
        }
        
        let secondExpt = expectation(description: "first handler")
        
        promise.nextHandler = { value in
            
            XCTAssert(value == 5)
            
            secondExpt.fulfill()
        }
        
        waitForExpectations(timeout: 0.2, handler: nil)
    }
    
    func testMapChaining() {
        
        let totalPromise = resolveAsync(10).then { $0 + 5 }
        
        let expt = expectation(description: "chained expt")
        
        totalPromise.nextHandler = { value in
         
            XCTAssert(value == 15)
            
            expt.fulfill()
        }
        
        waitForExpectations(timeout: 0.2, handler: nil)
    }
    
    func testMapToPromiseChaining() {
        
        let totalPromise = resolveAsync(10).then { (value: Int) in
        
            return Promise<Int>() { resolve, reject in
             
                resolve(value + 7)
            }
        }
        
        let expt = expectation(description: "chained expt")
        
        totalPromise.nextHandler = { value in
            
            XCTAssert(value == 17)
            
            expt.fulfill()
        }
        
        waitForExpectations(timeout: 0.2, handler: nil)
    }
    
    func testErrorChaining() {
        
        let totalPromise = rejectAsync().then { (value: Int) in
            
            return Promise<Int>() { resolve, reject in
                
                resolve(value + 7)
            }
        }
        
        let expt = expectation(description: "chained error")
        
        totalPromise.errorHandler = { err in
            
            expt.fulfill()
        }
        
        waitForExpectations(timeout: 0.2, handler: nil)
    }
    
    func testErrorChainingInternal() {
        
        let firstExpt = expectation(description: "first promise")
        
        let totalPromise = resolveAsync(8).then { (value: Int) -> Promise<Int> in
            
            firstExpt.fulfill()
            
            return rejectAsync()
        }
        
        let expt = expectation(description: "chained error")
        
        totalPromise.errorHandler = { err in
            
            expt.fulfill()
        }
        
        waitForExpectations(timeout: 0.2, handler: nil)
    }
    
    func testPromiseAll() {
        
        let promise = Promise.all(resolveImmediately(10), resolveAsync(100))
        
        let expt = expectation(description: "promise all")
        
        promise.nextHandler = { value in
            
            XCTAssert(value == [10, 100])
            
            expt.fulfill()
        }
        
        waitForExpectations(timeout: 0.2, handler: nil)
    }
}

func resolveImmediately<T>(_ value: T) -> Promise<T> {
    
    return Promise() { resolve, reject in
        
        resolve(value)
    }
}

func resolveAsync(_ value: Int) -> Promise<Int> {
    
    return Promise() { resolve, reject in
        
        DispatchQueue.main.async {
            
            resolve(value)
        }
    }
}

enum TestError: Error {
    
    case Default
}

func rejectImmediately(_ err: Error = TestError.Default) -> Promise<Int> {
    
    return Promise() { resolve, reject in
        
        reject(err)
    }
}

func rejectAsync(_ err: Error = TestError.Default) -> Promise<Int> {
    
    return Promise() { resolve, reject in
        
        DispatchQueue.main.async {
            
            reject(err)
        }
    }
}
