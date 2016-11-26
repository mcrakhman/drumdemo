//
//  Sequence.swift
//  DrumMachineDemo
//
//  Created by m.rakhmanov on 25.11.16.
//  Copyright © 2016 m.rakhmanov. All rights reserved.
//

import Foundation

typealias BeatSequence = [Bool]

struct SequenceNodeConstants {
    static let tempoKey = "tempo"
    static let velocityKey = "velocity"
    static let enabledKey = "enabled"
}

struct SequenceNode {
    var tempo: Double
    var velocity: Int
    var enabled: Bool
    
    let constants = SequenceNodeConstants.self
    
    static var empty: SequenceNode {
        return SequenceNode(tempo: 0, velocity: 127, enabled: false)
    }
    
    init(tempo: Double, velocity: Int, enabled: Bool) {
        self.tempo = tempo
        self.velocity = velocity
        self.enabled = enabled
    }
    
    init(dictionary: [String: Any]) {
        tempo = dictionary[constants.tempoKey] as? Double ?? 80.0
        enabled = dictionary[constants.enabledKey] as? Bool ?? false
        velocity = dictionary[constants.velocityKey] as? Int ?? 127
    }
    
    func toDictionary() -> [String: Any] {
        return [
            constants.tempoKey: tempo,
            constants.velocityKey: velocity,
            constants.enabledKey: enabled
        ]
    }
}

struct AdvancedBeatSequence {
    var instrument: Instruments
    var sequence: [[SequenceNode]]
    
    let length: Int
    let step: BeatStep
    
    init(length: Int, step: BeatStep, instrument: Instruments) {
        self.length = length
        self.instrument = instrument
        self.step = step
        
        let stepArray = Array(repeating: SequenceNode.empty, count: step.rawValue)
        sequence = Array(repeating: stepArray, count: length)
    }
    
    init(nodes: [[SequenceNode]], instrument: Instruments) {
        self.length = nodes.count
        sequence = nodes
        self.instrument = instrument
        
        self.step = BeatStep(rawValue: nodes.first!.count)!
    }
    
    init(dictionary: [[[String: Any]]], instrument: Instruments) {
        self.length = dictionary.count
        self.step = BeatStep(rawValue: dictionary.first!.count)!
        
        sequence = dictionary.map { node in
            node.map(SequenceNode.init)
        }
        self.instrument = instrument
    }
    
    subscript(row: Int, column: Int) -> SequenceNode {
        get {
            return sequence[row][column]
        }
        set {
            sequence[row][column] = newValue
        }
    }
    
    subscript(row: Int) -> [SequenceNode] {
        get {
            return sequence[row]
        }
        set {
            sequence[row] = newValue
        }
    }
    
    func toDictionary() -> [[[String: Any]]] {
        return sequence.map { node in
            node.map{ $0.toDictionary() }
        }
    }
}
