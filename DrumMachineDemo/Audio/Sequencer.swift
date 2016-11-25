//
//  Sequencer.swift
//  DrumMachineDemo
//
//  Created by m.rakhmanov on 25.11.16.
//  Copyright © 2016 m.rakhmanov. All rights reserved.
//

import Foundation

enum SequencerConstants {
    static let queueName = "sequencer.queue"
}

struct SequencerDisplayConfiguration {
    let position: Int
    let tempo: Double
}

protocol SequencerAudioEngine {
    func play(_ instrument: Instruments, withVelocity velocity: Int)
}

protocol SequencerDisplay {
    func show(_ configuration: SequencerDisplayConfiguration)
}

class Sequencer {
    var kickSequence: BeatSequence
    var snareSequence: BeatSequence
    var hatSequence: BeatSequence
    
    var counter: Int
    var length: Int
    
    let display: SequencerDisplay
    let audioEngine: SequencerAudioEngine
    let tempoCounter: TempoCounter
    
    let queue: DispatchQueue
    
    var tempo: Double {
        get {
            return tempoCounter.tempo
        }
        set {
            tempoCounter.tempo = newValue
        }
    }
    
    var isPlaying: Bool {
        return tempoCounter.isRunning
    }
    
    init(display: SequencerDisplay, audioEngine: SequencerAudioEngine, length: Int) {
        self.display = display
        self.audioEngine = audioEngine
        self.tempoCounter = TempoCounter()
        self.length = length
        counter = 0
        kickSequence = Array(repeating: false, count: length)
        snareSequence = Array(repeating: false, count: length)
        hatSequence = Array(repeating: false, count: length)
        
        tempoCounter.beatStep = .eighth
        
        queue = DispatchQueue(label: SequencerConstants.queueName,
                              qos: .userInteractive,
                              attributes: .concurrent)
        
        tempoCounter.handler = sound
    }
    
    func changeBeat(for instrument: Instruments, at position: Int) {
        guard position < length else { return }
        
        switch instrument {
        case .kick:
            kickSequence[position] = !kickSequence[position]
        case .snare:
            snareSequence[position] = !snareSequence[position]
        case .hat:
            hatSequence[position] = !hatSequence[position]
        }
    }
    
    func play() {
        tempoCounter.start()
    }
    
    func stop() {
        tempoCounter.stop()
    }

    private func sound() {
        queue.async {
            if self.kickSequence[self.counter] {
                self.audioEngine.play(.kick, withVelocity: 127)
            }
            if self.snareSequence[self.counter] {
                self.audioEngine.play(.snare, withVelocity: 127)
            }
            if self.hatSequence[self.counter] {
                self.audioEngine.play(.hat, withVelocity: 127)
            }
            let configuration = SequencerDisplayConfiguration(position: self.counter, tempo: self.tempo)
            
            DispatchQueue.main.async {
                self.display.show(configuration)
            }
            
            self.counter = (self.counter == self.length - 1) ? 0 : self.counter + 1
        }
    }
}
