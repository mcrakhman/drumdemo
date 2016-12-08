//
//  ParseService.swift
//  DrumMachineDemo
//
//  Created by m.rakhmanov on 26.11.16.
//  Copyright © 2016 m.rakhmanov. All rights reserved.
//

import Foundation
import Parse
import AudioKit

enum ParseServiceConstants {
    static let kickKey = "kick"
    static let snareKey = "snare"
    static let hatKey = "hat"
    static let filename = "sequence"
}

enum ParseServiceError: Error {
    case cannotParseFile
}

typealias SequenceTuple = (kickSequence: AdvancedBeatSequence, snareSequence: AdvancedBeatSequence, hatSequence: AdvancedBeatSequence)

class ParseService {
    
    let constants = ParseServiceConstants.self
    let serializer = JSONSerializer()
    let client = ParseClient()
    
    func saveSequences(sequences: [AdvancedBeatSequence]) throws -> Promise<Void> {
        let dictionary = [
            self.constants.kickKey: sequences[0].toDictionary(),
            self.constants.snareKey: sequences[1].toDictionary(),
            self.constants.hatKey: sequences[2].toDictionary()
        ]
        let data = try serializer.serialize(dictionary)
        
        return client.uploadData(data, withName: constants.filename)
    }
    
    func loadRandomSequences() -> Promise<[AdvancedBeatSequence]> {
        return client
            .downloadRandomFile()
            .then(parseData)
    }
    
    func loadAllSequences() -> Promise<[[AdvancedBeatSequence]]> {
        return client
            .downloadAllFiles()
            .then { try $0.map(self.parseData) }
    }

    private func parseData(data: Data) throws -> [AdvancedBeatSequence] {
        let deserialized = try serializer.deserialize(data) as? [String: [[[String: Any]]]]
        
        guard let kickSequence = deserialized?[constants.kickKey],
            let snareSequence = deserialized?[constants.snareKey],
            let hatSequence = deserialized?[constants.hatKey] else {
                throw ParseServiceError.cannotParseFile
        }
        let ks = AdvancedBeatSequence(dictionary: kickSequence, instrument: .kick)
        let ss = AdvancedBeatSequence(dictionary: snareSequence, instrument: .snare)
        let hs = AdvancedBeatSequence(dictionary: hatSequence, instrument: .hat)
        return [ks, ss, hs]
    }
}
