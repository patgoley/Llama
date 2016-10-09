//
//  Promise.swift
//  Llama
//
//  Created by Patrick Goley on 10/8/16.
//  Copyright © 2016 patrickgoley. All rights reserved.
//

import Foundation

enum State<T> {
    
    case pending, resolved(T), rejected(Error)
    
    var isPending: Bool {
        
        if case .pending = self {
            
            return true
        }
        
        return false
    }
}


public final class Promise<T> {
    
    private(set) var state: State<T> = .pending {
        
        willSet { precondition(state.isPending) }
    }
    
    var nextHandler: ((T) -> Void)? = nil {
        
        didSet {
            
            if case .resolved(let val) = state {
                
                nextHandler?(val)
            }
        }
    }
    
    var errorHandler: ((Error) -> Void)? = nil {
        
        didSet {
            
            if case .rejected(let err) = state {
                
                errorHandler?(err)
            }
        }
    }
    
    init() { }
    
    public init(_ work: (_ resolve: @escaping (T) -> Void, _ reject: @escaping (Error) -> Void) -> Void) {
        
        work(self.resolve, self.reject)
    }
    
    func resolve(value: T) {
        
        state = .resolved(value)
        
        nextHandler?(value)
    }
    
    func reject(_ error: Error) {
        
        state = .rejected(error)
        
        errorHandler?(error)
    }
    
    public func then<U>(_ map: @escaping (T) -> U) -> Promise<U> {
        
        let newPromise = Promise<U>()
        
        nextHandler = { (myResult: T) in
            
            let mapped = map(myResult)
            
            newPromise.resolve(value: mapped)
        }
        
        return newPromise
    }
    
    public func then<U>(_ mapToPromise: @escaping (T) -> Promise<U>) -> Promise<U> {
        
        let newPromise = Promise<U>()
        
        nextHandler = { (myResult: T) in
            
            let internalPromise = mapToPromise(myResult)
            
            internalPromise.nextHandler = { (newResult: U) in
                
                newPromise.resolve(value: newResult)
            }
            
            internalPromise.errorHandler = newPromise.reject
        }
        
        errorHandler = newPromise.reject
        
        return newPromise
    }
    
    public func `catch`<U>(_ map: @escaping (Error) -> U) -> Promise<U> {
        
        let newPromise = Promise<U>()
        
        errorHandler = { (error: Error) in
         
            let mapped = map(error)
            
            newPromise.resolve(value: mapped)
        }
        
        return newPromise
    }
}

