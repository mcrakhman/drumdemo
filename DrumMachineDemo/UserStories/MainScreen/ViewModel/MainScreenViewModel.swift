//
//  MainScreenViewModel.swift
//  DrumMachineDemo
//
//  Created by m.rakhmanov on 25.11.16.
//  Copyright © 2016 m.rakhmanov. All rights reserved.
//

import Foundation

enum MainScreenViewModelConstants {
    static let downloadComplete = "Download complete"
    static let uploadComplete = "Upload complete"
    static let uploadFailed = "Upload failed"
}

class MainScreenViewModel {
    
    let sampler: Sampler
    let view: MainScreenViewController
    let parseService = ParseService()
    
    var recordingPromise: Promise<Void>?
    
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
    
    func didTap(bar: Int) {
    }
    
    func didTapRecord() {
        if let promise = recordingPromise, promise.result == nil {
            return
        }
        
        view.animateRecord(true)
        sampler.changeMode(.recordingTempo)
        view.changeModeState(.recordingTempo)
        recordingPromise =
            sampler.recordBars()
            .then(parseService.saveSequences)
            .then {
                self.view.animateRecord(false)
                self.view.showAlert(message: MainScreenViewModelConstants.uploadComplete)
            }.error { error in
                self.view.animateRecord(false)
                self.view.showAlert(message: MainScreenViewModelConstants.uploadFailed)
        }
    }
    
    func didTapPlay() {
        if sampler.isPlaying {
            sampler.stop()
            view.changePlayingState(true)
        } else {
            sampler.play()
            view.changePlayingState(false)
        }
    }
    
    func didTapDownload() {
        view.animateDownload(true)
        sampler.changeMode(.playingTempo)
        view.changeModeState(.playingTempo)
        parseService
            .loadRandomSequences()
            .then(sampler.load)
            .then {
                self.view.animateDownload(false)
                self.view.showAlert(message: MainScreenViewModelConstants.downloadComplete)
        }
    }
    
    func didTapMode() {
        let newMode: SequencerMode
        if sampler.mode == .playingTempo {
            newMode = .recordingTempo
        } else {
            newMode = .playingTempo
        }
        sampler.changeMode(newMode)
        view.changeModeState(newMode)
    }
}
