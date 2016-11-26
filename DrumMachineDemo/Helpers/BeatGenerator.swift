//
//  BeatGenerator.swift
//  DrumMachineDemo
//
//  Created by m.rakhmanov on 26.11.16.
//  Copyright © 2016 m.rakhmanov. All rights reserved.
//

import Foundation

class BeatGenerator {
    
    let minVelocity = 80
    let maxVelocity = 127
    let defaultTempo = 60.0
    
    let baseHatPatterns = [
        [true, false, true, false],
        [true, true, true, false],
        [true, false, true, true],
        [true, false, false, false]
    ]
    let baseKickPatterns = [
        [true, false, true, false],
        [true, true, false, false],
        [true, false, false, true],
        [false, false, true, false],
        [false, false, false, true],
        [false, false, false, true]
    ]
    let baseSnarePatterns = [
        [true, false, false, false],
        [false, false, true, false]
    ]
    let emptyPattern = [false, false, false, false]
    
    func generateSequences(forBars bars: Int) -> [AdvancedBeatSequence] {
        var hatSequence: [[SequenceNode]] = []
        var kickSequence: [[SequenceNode]] = []
        var snareSequence: [[SequenceNode]] = []
        
        for _ in 0 ..< bars {
            var hatPattern = generatePatternsForBar(patterns: baseHatPatterns)
            let snarePattern = generatePatternsForBarSeparatedByEmptyPattern(patterns: baseSnarePatterns)
            var kickPattern = generatePatternsForBar(patterns: baseKickPatterns)
            kickPattern = merge(kickPattern, dominatingPattern: snarePattern)
            hatPattern = merge(hatPattern, dominatingPattern: snarePattern)
            
            hatSequence.append(sequence(from: hatPattern))
            snareSequence.append(sequence(from: snarePattern))
            kickSequence.append(sequence(from: kickPattern))
        }
        
        let kickBeatSequence = AdvancedBeatSequence(nodes: kickSequence, instrument: .kick)
        let snareBeatSequence = AdvancedBeatSequence(nodes: snareSequence, instrument: .snare)
        let hatBeatSequence = AdvancedBeatSequence(nodes: hatSequence, instrument: .hat)
        
        return [kickBeatSequence, snareBeatSequence, hatBeatSequence]
    }
    
    private func sequence(from pattern: [Bool]) -> [SequenceNode] {
        var sequence: [SequenceNode] = []
        for index in 0 ..< pattern.count {
            let velocity = index % 4 == 0 ? maxVelocity : randomInt(minVelocity ... maxVelocity)
            sequence.append(SequenceNode(tempo: defaultTempo,
                                         velocity: velocity,
                                         enabled: pattern[index]))
        }
        return sequence
    }
    
    private func generatePatternsForBar(patterns: [[Bool]]) -> [Bool] {
        var returnedValue: [Bool] = []
        
        for _ in 0 ..< 4 {
            returnedValue += patterns[randomInt(patterns.count)]
        }
        return returnedValue
    }
    
    private func generatePatternsForBarSeparatedByEmptyPattern(patterns: [[Bool]]) -> [Bool] {
        var returnedValue: [Bool] = []
        
        for _ in 0 ..< 2 {
            returnedValue += emptyPattern
            returnedValue += patterns[randomInt(patterns.count)]
        }
        return returnedValue
    }
    
    private func merge(_ weakPattern: [Bool], dominatingPattern: [Bool]) -> [Bool] {
        var returnedValue = Array(repeating: false, count: weakPattern.count)
        
        for index in 0 ..< weakPattern.count {
            returnedValue[index] = dominatingPattern[index] == true ? false : weakPattern[index]
        }
        return returnedValue
    }
}
