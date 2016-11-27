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

enum SequencerMode {
    case recordingTempo
    case playingTempo
}

struct SequencerDisplayConfiguration {
    let bar: Int
    let position: Int
    let tempo: Double
}

protocol SequencerAudioEngine {
    func play(_ instrument: Instruments, withVelocity velocity: Int)
}

protocol SequencerDisplay {
    func show(_ configuration: SequencerDisplayConfiguration)
    func shouldUpdate(kickSequence: [SequenceNode],
                      snareSequence: [SequenceNode],
                      hatSequence: [SequenceNode])
}

class Sequencer {
    var kickSequence: AdvancedBeatSequence
    var snareSequence: AdvancedBeatSequence
    var hatSequence: AdvancedBeatSequence
    
    var counter: SequenceStepCounter
    
    let display: SequencerDisplay
    let audioEngine: SequencerAudioEngine
    let tempoCounter: TempoCounter
    
    let queue: DispatchQueue
    
    var mode: SequencerMode = .recordingTempo
    
    var tempo: Double {
        get {
            return tempoCounter.tempo
        }
        set {
            if mode == .playingTempo {
                return
            }
            
            tempoCounter.tempo = newValue
        }
    }
    
    var isPlaying: Bool {
        return tempoCounter.isRunning
    }
    
    init(display: SequencerDisplay,
         audioEngine: SequencerAudioEngine,
         length: Int,
         step: BeatStep) {
        self.display = display
        self.audioEngine = audioEngine
        self.tempoCounter = TempoCounter()
        
        counter = SequenceStepCounter(length: length, step: step)
        
        kickSequence = AdvancedBeatSequence(length: length, step: step, instrument: .kick)
        snareSequence = AdvancedBeatSequence(length: length, step: step, instrument: .snare)
        hatSequence = AdvancedBeatSequence(length: length, step: step, instrument: .hat)
        
        tempoCounter.beatStep = step
        
        queue = DispatchQueue(label: SequencerConstants.queueName,
                              qos: .userInteractive,
                              attributes: .concurrent)
        
        tempoCounter.addHandler(sound)
    }
    
    func load(_ sequences: [AdvancedBeatSequence]) {
        queue.async(flags: .barrier) {
            self.kickSequence = sequences[0]
            self.snareSequence = sequences[1]
            self.hatSequence = sequences[2]
        }
    }
    
    func recordSequence() -> Promise<[AdvancedBeatSequence]> {
        return Promise<[AdvancedBeatSequence]> { fulfill, reject in
            var counter = SequenceStepCounter(length: self.counter.length, step: self.counter.step)
            var recordingStarted = false
            
            self.tempoCounter.addHandler {
                if self.counter.atEndOfBar {
                    recordingStarted = true
                }
                if recordingStarted {
                    counter.increment()
                    
                    if counter.atStartOfSequence {
                        fulfill([self.kickSequence, self.snareSequence, self.hatSequence])
                        self.tempoCounter.removeLast()
                    }
                }
            }
        }
    }
    
    func changeBeatAtCurrentBar(for instrument: Instruments, position: Int) {
        queue.async {
            self.changeBeat(for: instrument, at: self.counter.bar, position: position)
        }
    }
    
    func play() {
        queue.async {
            self.tempoCounter.start()
        }
    }
    
    func stop() {
        queue.async {
            self.tempoCounter.stop()
            self.counter.reset()
        }
    }

    private func changeBeat(for instrument: Instruments, at bar: Int, position: Int) {
        switch instrument {
            
        case .kick:
            kickSequence[bar, position].enabled = !kickSequence[bar, position].enabled
        case .snare:
            snareSequence[bar, position].enabled = !snareSequence[bar, position].enabled
        case .hat:
            hatSequence[bar, position].enabled = !hatSequence[bar, position].enabled
        }
    }
    
    private func sound() {
        queue.async {
            let position = self.counter.position
            let bar = self.counter.bar
            let endOfBar = self.counter.atEndOfBar
            
            self.playSounds(atBar: bar, position: position)
            
            if self.mode == .recordingTempo {
                self.updateTempo(atBar: bar, position: position)
            } else {
                self.tempoCounter.tempo = self.kickSequence[bar, position].tempo
            }
            
            let configuration = SequencerDisplayConfiguration(bar: bar, position: position, tempo: self.tempo)

            DispatchQueue.main.async {
                self.display.show(configuration)
                if endOfBar {
                    self.display.shouldUpdate(kickSequence: self.kickSequence[bar],
                                              snareSequence: self.snareSequence[bar],
                                              hatSequence: self.hatSequence[bar])
                }
            }
            
            self.counter.increment()
        }
    }
    
    private func playSounds(atBar bar: Int, position: Int) {
        if kickSequence[bar, position].enabled {
            audioEngine.play(.kick, withVelocity: kickSequence[bar, position].velocity)
        }
        if snareSequence[bar, position].enabled {
            audioEngine.play(.snare, withVelocity: snareSequence[bar, position].velocity)
        }
        if hatSequence[bar, position].enabled {
            audioEngine.play(.hat, withVelocity: hatSequence[bar, position].velocity)
        }
    }
    
    private func updateTempo(atBar bar: Int, position: Int) {
        kickSequence[bar, position].tempo = tempo
        snareSequence[bar, position].tempo = tempo
        hatSequence[bar, position].tempo = tempo
    }
}
