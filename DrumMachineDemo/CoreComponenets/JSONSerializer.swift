//
//  JSONSerializer.swift
//  DrumMachineDemo
//
//  Created by m.rakhmanov on 26.11.16.
//  Copyright © 2016 m.rakhmanov. All rights reserved.
//

import Foundation

class JSONSerializer {
    
    func deserialize(_ data: Data) throws -> Any {
        return try JSONSerialization.jsonObject(with: data)
    }
    
    func serialize(_ object: Any) throws -> Data {
        return try JSONSerialization.data(withJSONObject: object)
    }
}
