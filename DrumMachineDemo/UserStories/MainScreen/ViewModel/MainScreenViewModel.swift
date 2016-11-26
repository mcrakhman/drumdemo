//
//  MainScreenViewModel.swift
//  DrumMachineDemo
//
//  Created by m.rakhmanov on 25.11.16.
//  Copyright © 2016 m.rakhmanov. All rights reserved.
//

import Foundation

class MainScreenViewModel {
    
    let sampler: Sampler
    let view: MainScreenViewController
    let parseService = ParseService()
    
    init(view: MainScreenViewController) {
        self.view = view
        sampler = Sampler(display: view)
    }
    
    func viewIsReady() {
        sampler.play()
    }
    
    func didTap(_ instrument: Instruments, at index: Int) {
        sampler.changeBeat(for: instrument, position: index)
    }
    
    func shouldChangeMode() {
        //sampler.changeMode()
        sampler.recordBars()
            .then(onQueue: DispatchQueue.global(), parseService.saveSequences)
            .then {
                print("Cool")
            }.error { error in
                print(error)
        }
    }
}
