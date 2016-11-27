//
//  CircleButton.swift
//  DrumMachineDemo
//
//  Created by m.rakhmanov on 27.11.16.
//  Copyright © 2016 m.rakhmanov. All rights reserved.
//

import Foundation
import UIKit

enum CircleButtonState {
    case selected
    case unselected
}

class CircleButton: UIButton {
    
    var visualState: CircleButtonState = .unselected {
        didSet {
            if visualState == .selected {
                selectLayer()
            } else {
                unselectLayer()
            }
        }
    }
    
    override func awakeFromNib() {
        unselectLayer()
    }
    
    func selectLayer() {
        layer.cornerRadius = frame.width / 2.0
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1.0
    }
    
    func unselectLayer() {
        layer.cornerRadius = 0
        layer.borderWidth = 0
        layer.borderColor = UIColor.clear.cgColor
    }
}
