//
//  CADisplayLinkTimer.swift
//  DrumMachineDemo
//
//  Created by m.rakhmanov on 25.11.16.
//  Copyright © 2016 m.rakhmanov. All rights reserved.
//

import Foundation
import QuartzCore

enum BeatStep: Int {
    case fourth = 4
    case eighth = 8
    case sixteenth = 16
    case thirtyTwo = 32
}

typealias Handler = () -> ()

class TempoCounter {
    private var displayLink: CADisplayLink!
    private let frameRate = 60
    private var internalCounter = 0
    
    var tempo = 60.0
    var beatStep = BeatStep.fourth
    var handler: Handler?
    
    var isRunning: Bool {
        return !displayLink.isPaused
    }
    
    private var nextTickLength: Int {
        return Int(Double(frameRate) / (tempo / 60.0 * Double(beatStep.rawValue) / 4.0))
    }
    
    init() {
        displayLink = CADisplayLink(target: self, selector: #selector(fire))
        displayLink.preferredFramesPerSecond = frameRate
        displayLink.add(to: RunLoop.main, forMode: .commonModes)
        displayLink.isPaused = true
    }
    
    func start() {
        displayLink.isPaused = false
    }
    
    func stop() {
        displayLink.isPaused = true
    }
    
    @objc func fire() {
        internalCounter += 1
        
        if internalCounter >= nextTickLength {
            internalCounter = 0
            handler?()
        }
    }
}
