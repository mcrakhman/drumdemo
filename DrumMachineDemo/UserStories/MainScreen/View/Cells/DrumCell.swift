//
//  DrumCell.swift
//  DrumMachineDemo
//
//  Created by m.rakhmanov on 25.11.16.
//  Copyright © 2016 m.rakhmanov. All rights reserved.
//

import Foundation
import UIKit

class DrumCell: UICollectionViewCell {
    @IBOutlet weak var drumLabel: UILabel!
    
    override func awakeFromNib() {
        setActive(false)
    }
    
    func setActive(_ active: Bool) {
        drumLabel.text = active ? "1" : "0"
    }
    
    func changeState() {
        drumLabel.text = drumLabel.text == "1" ? "0" : "1"
    }
}
