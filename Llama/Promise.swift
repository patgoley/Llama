//
//  Promise.swift
//  Llama
//
//  Created by Patrick Goley on 10/8/16.
//  Copyright © 2016 patrickgoley. All rights reserved.
//

import Foundation

public enum State<T> {
    
    case pending, resolved(T), rejected(Error)
    
    var isPending: Bool {
        
        if case .pending = self {
            
            return true
        }
        
        return false
    }
}


public final class Promise<T> {
    
    private(set) var state: State<T> {
        
        set {
            
            queue.sync {
                
                precondition(_state.isPending)
                
                _state = newValue
            }
        }
        
        get {
            
            var currentState: State<T>!
            
            queue.sync {
                
                currentState = _state
            }
            
            return currentState
        }
    }
    
    private var _state: State<T> = .pending
    
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
    
    private let queue = DispatchQueue(label: "llama.promise.state", attributes: .concurrent)
    
    private var retainCycle: Promise<T>?
    
    init() { }
    
    public init(_ work: (_ resolve: @escaping (T) -> Void, _ reject: @escaping (Error) -> Void) -> Void) {
        
        retainCycle = self
        
        work(self.resolve, self.reject)
    }
    
    public init(_ work: (_ resolve: @escaping (T) -> Void) throws -> Void) {
        
        retainCycle = self
        
        do {
            
            try work(self.resolve)
            
        } catch let error {
            
            reject(error)
        }
    }
    
    func resolve(_ value: T) {
        
        state = .resolved(value)
        
        nextHandler?(value)
        
        dispose()
    }
    
    func reject(_ error: Error) {
        
        state = .rejected(error)
        
        errorHandler?(error)
        
        dispose()
    }
    
    private func dispose() {
        
        nextHandler = nil
        errorHandler = nil
        retainCycle = nil
    }
    
    public func then<U>(_ map: @escaping (T) throws -> U) -> Promise<U> {
        
        let newPromise = Promise<U>()
        
        nextHandler = { (myResult: T) in
            
            do {
                
                let mapped = try map(myResult)
                
                newPromise.resolve(mapped)
                
            } catch let error {
                
                newPromise.reject(error)
            }
        }
        
        return newPromise
    }
    
    public func then<U>(_ mapToPromise: @escaping (T) throws -> Promise<U>) -> Promise<U> {
        
        let newPromise = Promise<U>()
        
        nextHandler = { (myResult: T) in
            
            do {
                
                let internalPromise = try mapToPromise(myResult)
                
                internalPromise.nextHandler = { (newResult: U) in
                    
                    newPromise.resolve(newResult)
                }
                
                internalPromise.errorHandler = newPromise.reject
                
            } catch let error {
                
                newPromise.reject(error)
            }
        }
        
        errorHandler = newPromise.reject
        
        return newPromise
    }
    
    public func `catch`<U>(_ map: @escaping (Error) -> U) -> Promise<U> {
        
        let newPromise = Promise<U>()
        
        errorHandler = { (error: Error) in
         
            let mapped = map(error)
            
            newPromise.resolve(mapped)
        }
        
        return newPromise
    }
}
