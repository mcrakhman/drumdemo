//
//  Sampler.swift
//  DrumMachineDemo
//
//  Created by m.rakhmanov on 25.11.16.
//  Copyright © 2016 m.rakhmanov. All rights reserved.
//

import Foundation
import CoreMotion

enum SamplerConstants {
    static let startingBpm = 60.0
    static let additionalBpm = 30.0
    static let referenceAcceleration = 2.5
}

class Sampler {
    
    let sequencer: Sequencer
    let audioEngine: AudioEngine
    let motionEngine: MotionEngine
    let beatGenerator = BeatGenerator()
    
    var isPlaying: Bool {
        return sequencer.isPlaying
    }
    
    var mode: SequencerMode {
        return sequencer.mode
    }
    
    init(display: SequencerDisplay) {
        motionEngine = MotionEngine()
        audioEngine = AudioEngine()
        sequencer = Sequencer(display: display, audioEngine: audioEngine, length: 2, step: .sixteenth)
    }
    
    func play() {
        sequencer.play()
        motionEngine.startMotionUpdates { data in
            self.sequencer.tempo = self.convertToTempo(data)
            if data.userAcceleration > SamplerConstants.referenceAcceleration {
                let sequences = self.beatGenerator.generateSequences(forBars: 2)
                self.sequencer.load(sequences)
            }
        }
    }
    
    func stop() {
        sequencer.stop()
    }
    
    func recordBars() -> Promise<[AdvancedBeatSequence]> {
        return sequencer.recordSequence()
    }
    
    func changeMode(_ mode: SequencerMode) {
        sequencer.mode = mode
    }
    
    func changeBeat(for instrument: Instruments, position: Int) {
        sequencer.changeBeatAtCurrentBar(for: instrument, position: position)
    }
    
    func load(_ sequences: [AdvancedBeatSequence]) {
        sequencer.load(sequences)
    }
    
    private func convertToTempo(_ motion: CMDeviceMotion) -> Double {
        let length = abs(motion.gravity.y)
        return SamplerConstants.startingBpm + length * SamplerConstants.additionalBpm
    }
}
