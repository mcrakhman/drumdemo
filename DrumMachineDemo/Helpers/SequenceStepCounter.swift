//
//  SequenceStepCounter.swift
//  DrumMachineDemo
//
//  Created by m.rakhmanov on 25.11.16.
//  Copyright © 2016 m.rakhmanov. All rights reserved.
//

import Foundation

struct SequenceStepCounter {
    
    private let length: Int
    private let step: BeatStep
    
    private var _counter: Int
    
    var atEndOfBar: Bool {
        return position == 0
    }
    
    var position: Int {
        return _counter % step.rawValue
    }
    
    var bar: Int {
        return _counter / step.rawValue
    }
    
    var nextBar: Int {
        return bar + 1 == length ? 0 : bar + 1
    }
    
    init(length: Int, step: BeatStep) {
        self.length = length
        self.step = step
        
        _counter = 0
    }
    
    mutating func increment() {
        let maxValue = step.rawValue * length
        _counter = (_counter == maxValue - 1) ? 0 : _counter + 1
    }
    
    mutating func reset() {
        _counter = 0
    }
}
