//
//  Promise.swift
//  Llama
//
//  Created by Patrick Goley on 10/8/16.
//  Copyright © 2016 patrickgoley. All rights reserved.
//

import Foundation


final class Promise<T> {
    
    var nextHandler: ((T) -> Void)? = nil {
        
        didSet {
            
            if let val = self.settledValue {
                
                nextHandler?(val)
            }
        }
    }
    
    var errorHandler: ((Error) -> Void)? = nil {
        
        didSet {
            
            if let err = self.settledError {
                
                errorHandler?(err)
            }
        }
    }
    
    var settledValue: T? = nil
    
    var settledError: Error? = nil
    
    init() {
        
        
    }
    
    init(_ work: (_ resolve: @escaping (T) -> Void, _ reject: @escaping (Error) -> Void) -> Void) {
        
        work(self.resolve, self.reject)
    }
    
    func resolve(value: T) {
        
        self.settledValue = value
        
        nextHandler?(value)
    }
    
    func reject(_ error: Error) {
        
        self.settledError = error
        
        errorHandler?(error)
    }
    
    func then<U>(_ map: @escaping (T) -> U) -> Promise<U> {
        
        let newPromise = Promise<U>()
        
        self.nextHandler = { (myResult: T) in
            
            let mapped = map(myResult)
            
            newPromise.resolve(value: mapped)
        }
        
        return newPromise
    }
    
    func then<U>(_ mapToPromise: @escaping (T) -> Promise<U>) -> Promise<U> {
        
        let newPromise = Promise<U>()
        
        self.nextHandler = { (myResult: T) in
            
            let internalPromise = mapToPromise(myResult)
            
            internalPromise.nextHandler = { (newResult: U) in
                
                newPromise.resolve(value: newResult)
            }
            
            internalPromise.errorHandler = newPromise.reject
        }
        
        self.errorHandler = newPromise.reject
        
        return newPromise
    }
}
