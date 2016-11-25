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
        sampler.changeMode()
    }
}
