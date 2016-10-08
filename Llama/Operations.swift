//
//  Operations.swift
//  Llama
//
//  Created by Patrick Goley on 10/8/16.
//  Copyright © 2016 patrickgoley. All rights reserved.
//

import Foundation



extension Promise {
    
    static func all(_ promises: Promise<T>...) -> Promise<[T]> {
        
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
                
                newPromise.reject(error)
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            
            newPromise.resolve(value: values)
        }
        
        return newPromise
    }
}
