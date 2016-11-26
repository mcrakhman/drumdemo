//
//  AccelerationComparator.swift
//  DrumMachineDemo
//
//  Created by m.rakhmanov on 26.11.16.
//  Copyright © 2016 m.rakhmanov. All rights reserved.
//

import Foundation

import CoreMotion

func >(left: CMAcceleration, right: CMAcceleration) -> Bool {
    
    if fabs(left.x) > fabs(right.x) ||
        fabs(left.y) > fabs(right.y) ||
        fabs(left.z) > fabs(right.z) {
        return true
    }
    
    return false
}

func >(left: CMAcceleration, right: Double) -> Bool {
    
    if fabs(left.x) > fabs(right) ||
        fabs(left.y) > fabs(right) ||
        fabs(left.z) > fabs(right) {
        return true
    }
    
    return false
}

func <(left: CMAcceleration, right: CMAcceleration) -> Bool {
    return right > left
}
