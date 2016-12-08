//
//  ParseClient.swift
//  DrumMachineDemo
//
//  Created by m.rakhmanov on 26.11.16.
//  Copyright © 2016 m.rakhmanov. All rights reserved.
//

import Foundation
import Parse
import AudioKit

enum ParseError: Error {
    case failedToCreateFile
    case failedToDownloadFile
}

enum ParseClientConstants {
    static let parseClass = "Sequence"
    static let parseColumn = "File"
}

class ParseClient {
    
    let constants = ParseClientConstants.self
    
    let queue = DispatchQueue.global()
    
    func uploadData(_ data: Data, withName name: String) -> Promise<Void> {
        return Promise(onQueue: queue) { fulfill, reject in
            let newObject = PFObject(className: self.constants.parseClass)
            guard let file = PFFile(name: name, data: data)
                else {
                    reject(ParseError.failedToCreateFile)
                    return
            }
            
            newObject[self.constants.parseColumn] = file
            
            newObject.saveInBackground { success, error in
                if success {
                    fulfill()
                } else {
                    reject(error!)
                }
            }
        }
    }
    
    func downloadRandomFile() -> Promise<Data> {
        return allPFObjectsFromServer().then(downloadRandomFileFromPFObjects)
    }
    
    func downloadAllFiles() -> Promise<[Data]> {
        return allPFObjectsFromServer().then(onQueue: queue) { objects in
            let promises = objects.map(self.downloadFile)
            return combine(q: self.queue, promises: promises)
        }
    }
    
    func allPFObjectsFromServer() -> Promise<[PFObject]> {
        return Promise(onQueue: queue) { fulfill, reject in
            let query = PFQuery(className: self.constants.parseClass)
            query.findObjectsInBackground { objects, error in
                guard let objects = objects, error == nil
                    else {
                        reject(error!)
                        return
                }
                fulfill(objects)
            }
        }
    }
    
    func downloadFile(from object: PFObject) -> Promise<Data> {
        return Promise(onQueue: queue) { fulfill, reject in
           if let audio = object[self.constants.parseColumn] as? PFFile {
                audio.getDataInBackground { data, error in
                    guard let data = data, error == nil
                        else {
                            reject(error!)
                            return
                    }
                    fulfill(data)
                }
            } else {
                reject(ParseError.failedToDownloadFile)
            }
        }
    }
    
    func downloadRandomFileFromPFObjects(_ objects: [PFObject]) -> Promise<Data> {
        return Promise(onQueue: queue) { fulfill, reject in
            
            let randomElement = randomInt(objects.count)
            
            if let audio = objects[randomElement][self.constants.parseColumn] as? PFFile {
                audio.getDataInBackground { data, error in
                    guard let data = data, error == nil
                        else {
                            reject(error!)
                            return
                    }
                    fulfill(data)
                }
            } else {
                reject(ParseError.failedToDownloadFile)
            }
        }
    }
}
