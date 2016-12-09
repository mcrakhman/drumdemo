//
//  RecordingsScreenViewModel.swift
//  DrumMachineDemo
//
//  Created by m.rakhmanov on 25.11.16.
//  Copyright © 2016 m.rakhmanov. All rights reserved.
//

import Foundation

protocol RecordingsScreenViewModelDelegate: class {
    func didChooseSequence(sequence: [AdvancedBeatSequence])
}

class RecordingsScreenViewModel {
    
    unowned let view: RecordingsViewController
    unowned let delegate: RecordingsScreenViewModelDelegate
    
    let parseService = ParseService()
    let router = RecordingsScreenRouter()
    var sequences: [[AdvancedBeatSequence]] = []
    
    init(view: RecordingsViewController, delegate: RecordingsScreenViewModelDelegate) {
        self.view = view
        self.delegate = delegate
    }
    
    func viewIsReady() {
        parseService.loadAllSequences().then { sequences in
            self.sequences = sequences
            self.view.didLoadSequences()
        }
    }
    
    func didTap(recordingAt index: Int) {
        delegate.didChooseSequence(sequence: sequences[index])
        router.closeModule(from: view)
    }
}
