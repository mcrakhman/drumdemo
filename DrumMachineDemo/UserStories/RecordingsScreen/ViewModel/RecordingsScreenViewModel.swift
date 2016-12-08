//
//  RecordingsScreenViewModel.swift
//  DrumMachineDemo
//
//  Created by m.rakhmanov on 25.11.16.
//  Copyright © 2016 m.rakhmanov. All rights reserved.
//

import Foundation

class RecordingsScreenViewModel {
    
    let parseService = ParseService()
    
    func viewIsReady() {
        parseService.loadAllSequences().then { sequences in
            print("Loaded")
        }
    }
    
    func didTap(recordingAt index: Int) {
        
    }
}
