//
//  Promise.swift
//  DrumMachineDemo
//
//  Created by m.rakhmanov on 25.11.16.
//  Copyright © 2016 m.rakhmanov. All rights reserved.
//

import Foundation

typealias PromiseClosure<T> = (@escaping (T) -> (), @escaping (Error) -> ()) -> ()
typealias PromiseHandler<T> = (Result<T>) -> ()

enum Result<T> {
    case resolved(T)
    case rejected(Error)
}

class Promise<T> {
    let queue = DispatchQueue(label: "promise.queue", attributes: .concurrent)
    var handlers: [PromiseHandler<T>] = []
    
    private var _result: Result<T>?
    
    var result: Result<T>? {
        get {
            var r: Result<T>?
            queue.sync(flags: .barrier) {
                r = _result
            }
            return r
        }
        set {
            queue.async(flags: .barrier) {
                self._result = newValue
            }
        }
    }
    
    init(closure: @escaping PromiseClosure<T>) {
        closure(resolve, receivedError)
    }
    
    init(onQueue q: DispatchQueue, closure: @escaping PromiseClosure<T>) {
        q.async { closure(self.resolve, self.receivedError) }
    }
    
    func resolve(_ parameter: T) {
        result = .resolved(parameter)
        handlers.forEach { $0(result!) }
        handlers = []
    }
    
    func receivedError(_ error: Error) {
        result = .rejected(error)
        handlers.forEach { $0(result!) }
        handlers = []
    }
    
    func tryHandler(_ handler: @escaping (Result<T>) -> ()) {
        if let result = result {
            handler(result)
        } else {
            queue.async(flags: .barrier) {
                self.handlers.append(handler)
            }
        }
    }
    
    func exit(onQueue q: DispatchQueue = DispatchQueue.main, _ closure: @escaping (T) throws -> ()) {
        self.tryHandler { result in
            q.async {
                switch result {
                case .resolved(let parameter):
                    do {
                        try closure(parameter)
                    } catch _ {}
                case .rejected(_):
                    break
                }
            }
        }
    }
    
    @discardableResult
    func then(onQueue q: DispatchQueue = DispatchQueue.main, _ closure: @escaping (T) throws -> Void) -> Promise<Void> {
        return Promise<Void> { resolve, reject in
            self.tryHandler { result in
                q.async {
                    switch result {
                    case .resolved(let parameter):
                        do {
                            try closure(parameter)
                            resolve()
                        } catch let error {
                            reject(error)
                        }
                    case .rejected(let error):
                        reject(error)
                        break
                    }
                }
            }
        }
    }
    
    @discardableResult
    func then<U>(onQueue q: DispatchQueue = DispatchQueue.main, _ closure: @escaping (T) throws -> Promise<U>) -> Promise<U> {
        var result: Promise<U>!
        
        result = Promise<U> { resolve, reject in
            self.tryHandler { result in
                q.async {
                    switch result {
                    case .resolved(let parameter):
                        do {
                            let promise = try closure(parameter)
                            promise.exit(resolve)
                        } catch let error {
                            reject(error)
                        }
                    case .rejected(let error):
                        reject(error)
                        break
                    }
                }
            }
        }
        return result
    }
    
    @discardableResult
    func then<U>(onQueue q: DispatchQueue = DispatchQueue.main, _ closure: @escaping (T) throws -> U) -> Promise<U> {
        return Promise<U> { resolve, reject in
            self.tryHandler { result in
                q.async {
                    switch result {
                    case .resolved(let parameter):
                        do {
                            let converted = try closure(parameter)
                            resolve(converted)
                        } catch let error {
                            reject(error)
                        }
                    case .rejected(let error):
                        reject(error)
                        break
                    }
                }
            }
        }
    }
    
    @discardableResult
    func thenDelayed<U>(onQueue q: DispatchQueue = DispatchQueue.main, delay: TimeInterval, _ closure: @escaping (T) throws -> U) -> Promise<U> {
        return Promise<U> { resolve, reject in
            self.tryHandler { result in
                q.asyncAfter(deadline: .now() + delay) {
                    switch result {
                    case .resolved(let parameter):
                        do {
                            let converted = try closure(parameter)
                            resolve(converted)
                        } catch let error {
                            reject(error)
                        }
                    case .rejected(let error):
                        reject(error)
                        break
                    }
                }
            }
        }
    }
    
    @discardableResult
    func error(_ closure: @escaping (Error) -> Void) -> Promise<T> {
        tryHandler { result in
            switch result {
            case .resolved(_):
                break
            case .rejected(let error):
                closure(error)
                break
            }
        }
        return self
    }
}
