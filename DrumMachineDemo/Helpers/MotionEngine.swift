//
//  MotionEngine.swift
//  DrumMachineDemo
//
//  Created by m.rakhmanov on 25.11.16.
//  Copyright © 2016 m.rakhmanov. All rights reserved.
//

import Foundation
import CoreMotion

class MotionEngine {
    
    let motionQueue = OperationQueue.main
    let motionManager = CMMotionManager()
    
    func startMotionUpdates(_ motionClosure: @escaping (CMDeviceMotion) -> ()) {
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        if motionManager.isDeviceMotionAvailable {
            motionManager.startDeviceMotionUpdates(to: motionQueue) { data, error in
                guard let data = data else { return }
                motionClosure(data)
            }
        }
    }
}
