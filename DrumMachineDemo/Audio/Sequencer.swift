//
//  Sequencer.swift
//  DrumMachineDemo
//
//  Created by m.rakhmanov on 25.11.16.
//  Copyright © 2016 m.rakhmanov. All rights reserved.
//

import Foundation

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
        tempoCounter.handler = sound
    }
    
    func changeBeat(for instrument: Instruments, at position: Int) {
        guard position < length - 1 else { return }
        
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
        if kickSequence[counter] {
            audioEngine.play(.kick, withVelocity: 127)
        }
        if snareSequence[counter] {
            audioEngine.play(.snare, withVelocity: 127)
        }
        if hatSequence[counter] {
            audioEngine.play(.hat, withVelocity: 127)
        }
        let configuration = SequencerDisplayConfiguration(position: counter, tempo: tempo)
        display.show(configuration)
        
        counter = (counter == length - 1) ? 0 : counter + 1
    }
}
