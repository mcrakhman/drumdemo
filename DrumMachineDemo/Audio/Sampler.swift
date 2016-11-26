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
    static let startingBpm = 80.0
    static let additionalBpm = 40.0
}

class Sampler {
    
    let sequencer: Sequencer
    let audioEngine: AudioEngine
    let motionEngine: MotionEngine
    
    init(display: SequencerDisplay) {
        motionEngine = MotionEngine()
        audioEngine = AudioEngine()
        sequencer = Sequencer(display: display, audioEngine: audioEngine, length: 2, step: .sixteenth)
    }
    
    func play() {
        sequencer.play()
        motionEngine.startMotionUpdates { data in
            self.sequencer.tempo = self.convertToTempo(data)
        }
    }
    
    func stop() {
        sequencer.stop()
    }
    
    func recordBars() -> Promise<[AdvancedBeatSequence]> {
        return Promise { fulfill, reject in
            fulfill([self.sequencer.kickSequence, self.sequencer.snareSequence, self.sequencer.hatSequence])
        }
    }
    
    func changeMode() {
        sequencer.mode = sequencer.mode == .playingTempo ? .recordingTempo : .playingTempo
    }
    
    func changeBeat(for instrument: Instruments, position: Int) {
        sequencer.changeBeatAtCurrentBar(for: instrument, position: position)
    }
    
    func load(_ beatSequence: BeatSequence, for instrument: Instruments) {
        
    }
    
    private func convertToTempo(_ motion: CMDeviceMotion) -> Double {
        let length = abs(motion.gravity.y)
        return SamplerConstants.startingBpm + length * SamplerConstants.additionalBpm
    }
}
