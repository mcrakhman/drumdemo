//
//  ArrowDownCell.swift
//  DrumMachineDemo
//
//  Created by m.rakhmanov on 25.11.16.
//  Copyright © 2016 m.rakhmanov. All rights reserved.
//

import Foundation
import UIKit

class ArrowDownCell: UICollectionViewCell {
    @IBOutlet weak var drumLabel: UILabel!
    
    func setActive(_ active: Bool) {
        drumLabel.text = active ? "↓" : ""
    }
}
