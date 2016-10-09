//
//  PromiseExtensions.swift
//  Llama
//
//  Created by Patrick Goley on 10/8/16.
//  Copyright © 2016 patrickgoley. All rights reserved.
//

import Foundation



public extension Promise {
    
    convenience init(resolve value: T) {
        
        self.init()
        
        resolve(value)
    }
    
    convenience init(reject error: Error) {
        
        self.init()
        
        reject(error)
    }
    
    static func all(_ promises: Promise<T>...) -> Promise<[T]> {
        
        return all(promises)
    }
    
    static func all(_ promises: [Promise<T>]) -> Promise<[T]> {
        
        let newPromise = Promise<[T]>()
        
        let group = DispatchGroup()
        
        var values = [T]()
        
        promises.forEach { promise in
            
            group.enter()
            
            promise.nextHandler = { value in
                
                //FIXME: this needs to be made thread safe
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
            
            if newPromise.state.isPending {
                
                newPromise.resolve(values)
            }
        }
        
        return newPromise
    }
}
