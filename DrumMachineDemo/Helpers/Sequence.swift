//
//  Sequence.swift
//  DrumMachineDemo
//
//  Created by m.rakhmanov on 25.11.16.
//  Copyright © 2016 m.rakhmanov. All rights reserved.
//

import Foundation

typealias BeatSequence = [Bool]

struct SequenceNode {
    var tempo: Double
    var velocity: Int
    var enabled: Bool
    
    static var empty: SequenceNode {
        return SequenceNode(tempo: 0, velocity: 127, enabled: false)
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
}
