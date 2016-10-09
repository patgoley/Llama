//
//  Operations.swift
//  Llama
//
//  Created by Patrick Goley on 10/8/16.
//  Copyright © 2016 patrickgoley. All rights reserved.
//

import Foundation



public extension Promise {
    
    static func resolve(_ value: T) -> Promise<T> {
        
        let promise = Promise<T>()
        
        promise.resolve(value: value)
        
        return promise
    }
    
    static func reject(_ error: Error) -> Promise<T> {
        
        let promise = Promise<T>()
        
        promise.reject(error)
        
        return promise
    }
    
    static func all(_ promises: Promise<T>...) -> Promise<[T]> {
        
        return all(promises)
    }
    
    static func all(_ promises: [Promise<T>]) -> Promise<[T]> {
        
        let newPromise = Promise<[T]>()
        
        var values = [T]()
        
        let group = DispatchGroup()
        
        promises.forEach { promise in
            
            group.enter()
            
            promise.nextHandler = { value in
                
                values.append(value)
                
                group.leave()
            }
            
            promise.errorHandler = { error in
                
                if newPromise.state.isPending {
                    
                    newPromise.reject(error)
                }
                
                group.leave()
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            
            newPromise.resolve(value: values)
        }
        
        return newPromise
    }
}
