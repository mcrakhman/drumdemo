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
    static let downloadFailed = "Download failed"
    static let uploadComplete = "Upload complete"
    static let uploadFailed = "Upload failed"
}

class MainScreenViewModel: RecordingsScreenViewModelDelegate {
    
    let sampler: Sampler
    unowned let view: MainScreenViewController
    let router = MainScreenRouter()
    let parseService = ParseService()
    
    var recordingPromise: Promise<Void>?
    var downloadingPromise: Promise<Void>?
    
    var recordingPromiseResolved: Bool {
        return recordingPromise != nil && recordingPromise!.result != nil
    }
    
    var downloadingPromiseResolved: Bool {
        return downloadingPromise != nil && downloadingPromise!.result != nil
    }
    
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
        view.changeMode(.recordingTempo)
        
        recordingPromise =
            sampler.recordBars()
            .then(parseService.saveSequences)
            .then {
                self.view.animateRecord(false)
                self.view.showAlert(message: MainScreenViewModelConstants.uploadComplete)
            }
            .error { error in
                self.view.animateRecord(false)
                self.view.showAlert(message: MainScreenViewModelConstants.uploadFailed)
        }
    }
    
    func didTapPlay() {
        if sampler.isPlaying {
            sampler.stop()
            view.changePlayingState(false)
        } else {
            sampler.play()
            view.changePlayingState(true)
        }
    }
    
    func didTapDownload() {
        sampler.stop()
        view.changePlayingState(false)
        router.openRecordings(from: view, delegate: self)
    }
    
    func didTapMode() {
        let newMode: SequencerMode
        if sampler.mode == .playingTempo {
            newMode = .recordingTempo
        } else {
            newMode = .playingTempo
        }
        sampler.changeMode(newMode)
        view.changeMode(newMode)
    }
    
    func didChooseSequence(sequence: [AdvancedBeatSequence]) {
        sampler.load(sequence)
        sampler.changeMode(.playingTempo)
        view.changeMode(.playingTempo)
        sampler.play()
        view.changePlayingState(true)
    }
}
