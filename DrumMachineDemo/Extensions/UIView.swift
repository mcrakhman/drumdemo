//
//  UIView.swift
//  DrumMachineDemo
//
//  Created by m.rakhmanov on 27.11.16.
//  Copyright © 2016 m.rakhmanov. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func blink(_ duration: Double) {
        UIView.animate(withDuration: duration,
                       delay: 0.0,
                       options: [.autoreverse, .repeat],
                       animations: {
                            self.alpha = 0.5
                       },
                       completion: { bool in
                            self.alpha = 1.0
                       })
    }
}
