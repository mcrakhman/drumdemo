//
//  AudioEngine.swift
//  DrumMachineDemo
//
//  Created by m.rakhmanov on 25.11.16.
//  Copyright © 2016 m.rakhmanov. All rights reserved.
//

import Foundation
import AudioKit

enum AudioEngineConstants {
    static let kickName = "K - Deep"
    static let snareName = "S - Clean"
    static let hatName = "H - Nice"
}

class AudioEngine: SequencerAudioEngine {
    
    let kick: AKSampler
    let hat: AKSampler
    let snare: AKSampler
    let reverb: AKReverb
    
    let constants = AudioEngineConstants.self
    
    init() {
        kick = AKSampler()
        snare = AKSampler()
        hat = AKSampler()
        
        kick.loadWav(constants.kickName)
        snare.loadWav(constants.snareName)
        hat.loadWav(constants.hatName)
        
        let mix = AKMixer(kick, snare, hat)
        reverb = AKReverb(mix)
        reverb.loadFactoryPreset(.mediumRoom)
        
        AudioKit.output = reverb
        AudioKit.start()
    }
    
    func play(_ instrument: Instruments, withVelocity velocity: Int) {
        let sampler: AKSampler
        switch instrument {
        case .kick:
            sampler = kick
        case .snare:
            sampler = snare
        case .hat:
            sampler = hat
        }
        sampler.play(velocity: velocity)
    }
}
