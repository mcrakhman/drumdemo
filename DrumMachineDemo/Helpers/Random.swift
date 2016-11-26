//
//  Random.swift
//  DrumMachineDemo
//
//  Created by m.rakhmanov on 26.11.16.
//  Copyright © 2016 m.rakhmanov. All rights reserved.
//

import Foundation

func randomInt(_ max: Int) -> Int {
    return Int(arc4random_uniform(UInt32(max)))
}

func randomInt(_ range: CountableClosedRange<Int>) -> Int {
    return range.lowerBound + Int(arc4random_uniform(UInt32(range.upperBound - range.lowerBound + 1)))
}
