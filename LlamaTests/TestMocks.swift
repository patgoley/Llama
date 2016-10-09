//
//  TestMocks.swift
//  Llama
//
//  Created by Patrick Goley on 10/8/16.
//  Copyright © 2016 patrickgoley. All rights reserved.
//

import Foundation
@testable import Llama


func resolveImmediately<T>(_ value: T) -> Promise<T> {
    
    return Promise() { resolve in
        
        resolve(value)
    }
}

func resolveAsync(_ value: Int) -> Promise<Int> {
    
    return Promise() { resolve in
        
        DispatchQueue.main.async {
            
            resolve(value)
        }
    }
}

enum TestError: Error {
    
    case Default
}

func rejectImmediately(_ err: Error = TestError.Default) -> Promise<Int> {
    
    return Promise() { resolve in
        
        throw err
    }
}

func rejectAsync(_ err: Error = TestError.Default) -> Promise<Int> {
    
    return Promise() { resolve, reject in
        
        DispatchQueue.main.async {
            
            reject(err)
        }
    }
}
